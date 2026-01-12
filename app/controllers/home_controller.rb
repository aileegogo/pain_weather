class HomeController < ApplicationController
  def index
    @city_ko = params[:city].presence || "동탄시"
    
    city_map = { 
      "동탄시" => "Hwaseong", "서울시" => "Seoul", "부산시" => "Busan", 
      "대구시" => "Daegu", "제주시" => "Jeju", "남원시" => "Namwon" 
    }
    city_en = city_map[@city_ko] || "Seoul"

    service = DailyPainService.new(city_en, @city_ko)
    if service.run_daily_process
      # [핵심 수정] 반드시 현재 검색한(@city_ko) 도시의 데이터만 찾아서 가져옵니다.
      @weather = DailyWeather.where(location: @city_ko).order(created_at: :desc).first
    end
  end
end