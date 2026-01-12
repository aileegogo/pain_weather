class HomeController < ApplicationController
  def index
    # 1. 도시 이름을 확실히 받아옵니다.
    @city_ko = params[:city].presence || "동탄시"
    
    # 2. 도시명 매핑 (남원, 대구 등 추가)
    city_map = { 
      "동탄시" => "Hwaseong", "서울시" => "Seoul", "부산시" => "Busan", 
      "대구시" => "Daegu", "제주시" => "Jeju", "남원시" => "Namwon" 
    }
    city_en = city_map[@city_ko] || "Seoul"

    # 3. [중요] 검색 시 기존 데이터를 찾지 않고 '새로운 인스턴스'로 서비스를 실행합니다.
    service = DailyPainService.new(city_en, @city_ko)
    
    if service.run_daily_process
      # 4. 방금 '해당 도시' 이름으로 생성된 가장 마지막 데이터를 정확히 가져옵니다.
      @weather = DailyWeather.where(location: @city_ko).order(created_at: :desc).first
    end
  end
end