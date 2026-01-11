class HomeController < ApplicationController
  def index
    @city_ko = params[:city].presence || "동탄시"
    
    # 1. DB에서 해당 도시의 최신 데이터를 찾습니다.
    @weather = DailyWeather.where(location: @city_ko).last
    
    # 2. 데이터가 없으면 새로 생성합니다.
    if @weather.nil?
      # 도시 이름 매핑 (오타 방지를 위해 변수로 분리)
      city_map = { 
        "동탄시" => "Hwaseong", 
        "서울시" => "Seoul", 
        "부산시" => "Busan", 
        "대구시" => "Daegu", 
        "제주시" => "Jeju",
        "남원시" => "Namwon" 
      }
      city_en = city_map[@city_ko] || "Seoul"

      # 서비스 호출
      service = DailyPainService.new(city_en, @city_ko)
      if service.run_daily_process
        @weather = DailyWeather.where(location: @city_ko).last
      end
    end
  end
end