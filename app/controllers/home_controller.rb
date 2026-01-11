def index
  @city_ko = params[:city].presence || "동탄시"
  
  # 1. 먼저 DB에서 해당 도시의 '오늘' 데이터를 찾습니다.
  @weather = DailyWeather.where(location: @city_ko).last
  
  # 2. 만약 데이터가 없거나 너무 오래되었다면 새로 생성합니다.
  if @weather.nil?
    # 도시 한글명에 맞는 영어 이름을 매칭합니다.
    city_map = { "동탄시" => "Hwaseong", "서울시" => "Seoul", "부산시" => "Busan", "대구시" => "Daegu", "제주시" => "Jeju" }
    city_en = city_map[@city_ko] || "Seoul"

    # DailyPainService를 호출하여 실시간 날씨를 가져오고 DB에 저장합니다.
    service = DailyPainService.new(city_en, @city_ko)
    if service.run_daily_process
      # 성공적으로 저장되었다면 다시 DB에서 최신 데이터를 가져옵니다.
      @weather = DailyWeather.where(location: @city_ko).last
    end
  end
end