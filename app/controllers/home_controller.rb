class HomeController < ApplicationController
  def index
    # 1. 사용자가 입력한 도시명을 가져옵니다. 없으면 "동탄시"를 기본값으로 합니다.
    @city_ko = params[:city].presence || "동탄시"
    
    # 2. 도시 이름 매핑 (이 리스트에 없는 도시는 기본적으로 서울 날씨를 가져옵니다)
    city_map = { 
      "동탄시" => "Hwaseong", 
      "서울시" => "Seoul", 
      "부산시" => "Busan", 
      "대구시" => "Daegu", 
      "제주시" => "Jeju",
      "남원시" => "Namwon" 
    }
    city_en = city_map[@city_ko] || "Seoul"

    # 3. 서비스 실행 (입력받은 도시의 영문명과 한글명을 정확히 전달)
    service = DailyPainService.new(city_en, @city_ko)
    
    if service.run_daily_process
      # 4. 방금 생성된 '해당 도시'의 최신 데이터를 가져와 화면에 보여줍니다.
      @weather = DailyWeather.where(location: @city_ko).order(created_at: :desc).first
    end
  end
end