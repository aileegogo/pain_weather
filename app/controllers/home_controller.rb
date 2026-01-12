class HomeController < ApplicationController
  def index
    # 1. 사용자가 검색창에 입력한 값(params[:city])을 '최우선'으로 가져옵니다.
    @city_ko = params[:city].presence || "동탄시"
    
    # 2. 영문 매핑 (사용자님이 어제 확인하신 그 영문명들입니다)
    city_map = { 
      "동탄시" => "Hwaseong", "서울시" => "Seoul", "부산시" => "Busan", 
      "대구시" => "Daegu", "제주시" => "Jeju", "남원시" => "Namwon" 
    }
    city_en = city_map[@city_ko] || "Seoul"

    # 3. 서비스 실행 (중요: 입력받은 @city_ko를 서비스에 강제로 주입)
    service = DailyPainService.new(city_en, @city_ko)
    
    if service.run_daily_process
      # 4. 방금 생성된 '그 도시'의 데이터만 정확히 골라내어 화면에 뿌립니다.
      @weather = DailyWeather.where(location: @city_ko).order(created_at: :desc).first
    end
  end
end