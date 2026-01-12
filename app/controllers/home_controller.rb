class HomeController < ApplicationController
  def index
    # 1. 검색창에 입력한 도시명을 확실히 잡습니다.
    @city_ko = params[:city].presence || "동탄시"
    
    # 2. 전국 주요 도시 매핑 (속초, 강릉 포함)
    city_map = { 
      "동탄시" => "Hwaseong", "서울시" => "Seoul", "부산시" => "Busan", 
      "강릉시" => "Gangneung", "속초시" => "Sokcho", "인천시" => "Incheon",
      "대구시" => "Daegu", "제주시" => "Jeju"
    }
    city_en = city_map[@city_ko] || "Seoul"

    # 3. 서비스 실행 (새로운 실시간 데이터 생성)
    service = DailyPainService.new(city_en, @city_ko)
    
    if service.run_daily_process
      # [핵심 수정] 반드시 '방금 검색한 도시명'과 일치하는 데이터만 가져옵니다.
      @weather = DailyWeather.where(location: @city_ko).order(created_at: :desc).first
    end
  end
end