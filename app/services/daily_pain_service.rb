class DailyPainService
  def initialize(city_en, city_ko)
    @city_en = city_en # 영어 이름 (API 조회용)
    @city_ko = city_ko # 한글 이름 (DB 저장용)
    @api_key = ENV['OPENWEATHER_API_KEY']
    @openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])
  end

  def run_daily_process
    weather_data = fetch_weather
    return false unless weather_data

    # GPT에게 1,000자 이상의 상세 블로그 포스팅을 요구
    prompt = <<~TEXT
      너는 기상병 전문의이자 파워 블로거야. 
      #{@city_ko}의 현재 날씨(기온 #{weather_data[:temp]}도, 기압 #{weather_data[:pressure]}hPa)를 분석하여 상세한 건강 리포트를 작성해줘.
      ## 소제목을 3개 이상 사용하고, 관절염과 두통 환자를 위한 의학적 조언을 포함하여 1,000자 이상 아주 상세하게 작성해줘.
    TEXT

    res = @openai_client.chat(parameters: { 
      model: "gpt-4o-mini", 
      messages: [{role: "user", content: prompt}],
      max_tokens: 2000, 
      temperature: 0.7 
    })
    
    ai_content = res.dig("choices", 0, "message", "content")

    # DB에 현재 검색한 한글 이름(@city_ko)으로 저장
    DailyWeather.create!(
      location: @city_ko,
      pressure: weather_data[:pressure],
      humidity: weather_data[:humidity],
      temp: weather_data[:temp],
      pain_level: (weather_data[:pressure] > 1010 ? 1 : 2),
      ai_content: ai_content
    )
    true
  end

  private

  def fetch_weather
    # [핵심] @city_en 변수가 API URL에 정확히 꽂혀야 도시마다 데이터가 달라집니다.
    encoded_city = CGI.escape(@city_en)
    url = "https://api.openweathermap.org/data/2.5/weather?q=#{encoded_city}&appid=#{@api_key}&units=metric"
    
    response = HTTParty.get(url)
    if response.success?
      {
        pressure: response['main']['pressure'],
        humidity: response['main']['humidity'],
        temp: response['main']['temp'].to_f.round(1)
      }
    else
      nil
    end
  end
end