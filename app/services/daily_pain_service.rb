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

    # 프롬프트: 400자 이하로 핵심만 요청 (서버 속도 향상)
    prompt = <<~TEXT
      너는 기상병 전문의야. #{@city_ko} 날씨(기온 #{weather_data[:temp]}도, 기압 #{weather_data[:pressure]}hPa)를 분석해줘.
      반드시 '공백 포함 400자 이내'로 짧고 강렬하게 핵심 건강 조언만 작성할 것.
    TEXT

    res = @openai_client.chat(parameters: { 
      model: "gpt-4o-mini", 
      messages: [{role: "user", content: prompt}],
      max_tokens: 600, 
      temperature: 0.7 
    })
    
    ai_content = res.dig("choices", 0, "message", "content")

    DailyWeather.create!(
      location: @city_ko,
      pressure: weather_data[:pressure],
      humidity: weather_data[:humidity],
      temp: weather_data[:temp],
      pain_level: (weather_data[:pressure].to_i > 1010 ? 1 : 2),
      ai_content: ai_content
    )
    true
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