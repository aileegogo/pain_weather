class HomeController < ApplicationController
  def index
    @city_ko = params[:city].presence || "동탄시"
    
    city_map = { 
      "동탄시" => "Hwaseong", "서울시" => "Seoul", "부산시" => "Busan", 
      "강릉시" => "Gangneung", "속초시" => "Sokcho", "인천시" => "Incheon",
      "대구시" => "Daegu", "제주시" => "Jeju"
    }
    city_en = city_map[@city_ko] || "Seoul"

    service = DailyPainService.new(city_en, @city_ko)
    if service.run_daily_process
      # [최종 수정] id: :desc 로 변경하여 조회 정확도를 100%로 높입니다.
      @weather = DailyWeather.where(location: @city_ko).order(id: :desc).first
    end
  end
end