def index
  @city_ko = params[:city].presence || "동탄시"
  
  # [수정] 테스트 기간에는 기존 데이터를 찾지 않고 바로 서비스를 실행하여 갱신합니다.
  city_map = { 
    "동탄시" => "Hwaseong", "서울시" => "Seoul", "부산시" => "Busan", 
    "대구시" => "Daegu", "제주시" => "Jeju", "남원시" => "Namwon" 
  }
  city_en = city_map[@city_ko] || "Seoul"

  service = DailyPainService.new(city_en, @city_ko)
  if service.run_daily_process
    # 새로 생성된 가장 최신 데이터를 가져옵니다.
    @weather = DailyWeather.where(location: @city_ko).last
  end
end