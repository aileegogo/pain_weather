class DailyPainService
  def initialize(city_en, city_ko)
    @city_en = city_en
    @city_ko = city_ko
    @api_key = ENV['OPENWEATHER_API_KEY']
    @openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])
  end

  def run_daily_process
    weather_data = fetch_weather
    return false unless weather_data

    # 400자 이내 요청으로 서버 속도 10배 향상
    prompt = <<~TEXT
      너는 기상병 전문의야. #{@city_ko} 날씨(기온 #{weather_data[:temp]}도, 기압 #{weather_data[:pressure]}hPa)를 분석해줘.
      반드시 공백 포함 400자 이내로 짧게 건강 조언만 작성할 것.
    TEXT

    res = @openai_client.chat(parameters: { 
      model: "gpt-4o-mini", 
      messages: [{role: "user", content: prompt}],
      max_tokens: 600, 
      temperature: 0.7 
    })
    
    ai_content = res.dig("choices", 0, "message", "content")

    # DB에 실제 API 수치와 GPT 결과 저장
    DailyWeather.create!(
      location: @city_ko,
      pressure: weather_data[:pressure],
      humidity: weather_data[:humidity],
      temp: weather_data[:temp],
      pain_level: (weather_data[:pressure].to_i > 1010 ? 1 : 2),
      ai_content: ai_content
    )
    true
  rescue => e
    Rails.logger.error "DailyPainService Error: #{e.message}"
    false
  end

  private

  def fetch_weather
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