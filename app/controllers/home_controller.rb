class HomeController < ApplicationController
  def index
    # 1. 검색창의 도시명을 가져옵니다. (기본값: 동탄시)
    @city_ko = params[:city].presence || "동탄시"
    
    # 2. 영문 매핑
    city_map = { 
      "동탄시" => "Hwaseong", "서울시" => "Seoul", "부산시" => "Busan", 
      "대구시" => "Daegu", "제주시" => "Jeju", "남원시" => "Namwon" 
    }
    city_en = city_map[@city_ko] || "Seoul"

    # 3. 서비스 실행 (400자 리포트 생성)
    service = DailyPainService.new(city_en, @city_ko)
    if service.run_daily_process
      # 4. 해당 도시의 가장 최신 데이터를 가져옵니다.
      @weather = DailyWeather.where(location: @city_ko).order(created_at: :desc).first
    end
  end
end