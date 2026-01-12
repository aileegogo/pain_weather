# app/services/daily_pain_service.rb

# ... 중략 ...
    prompt = <<~TEXT
      너는 기상병 전문의야. #{@city_ko} 날씨(기온 #{weather_data[:temp]}도, 기압 #{weather_data[:pressure]}hPa)를 분석해줘.
      1. 관절염/두통 환자를 위한 핵심 조언.
      2. 반드시 공백 포함 400자 이내로 짧고 강렬하게 작성할 것.
    TEXT
# ... 중략 ...