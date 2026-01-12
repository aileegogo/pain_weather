class HomeController < ApplicationController
  def index
    @city_ko = params[:city].presence || "동탄시"
    
    # 도시 영어 이름 매핑
    city_map = { 
      "동탄시" => "Hwaseong", 
      "서울시" => "Seoul", 
      "부산시" => "Busan", 
      "대구시" => "Daegu", 
      "제주시" => "Jeju",
      "남원시" => "Namwon" 
    }
    city_en = city_map[@city_ko] || "Seoul"

    # 무조건 실시간 데이터를 가져오도록 서비스 실행
    service = DailyPainService.new(city_en, @city_ko)
    if service.run_daily_process
      # 방금 생성된 가장 최신 데이터를 DB에서 가져와 화면에 전달
      @weather = DailyWeather.where(location: @city_ko).last
    end
  end
end