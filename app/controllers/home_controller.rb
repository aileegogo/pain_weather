class HomeController < ApplicationController
  def index
    # 1. 검색어 확인 (기본값: 동탄시)
    @city_ko = params[:city].presence || "동탄시"
    
    # 2. 전국 주요 도시 매핑
    city_map = { 
      "동탄시" => "Hwaseong", "서울시" => "Seoul", "부산시" => "Busan", 
      "강릉시" => "Gangneung", "속초시" => "Sokcho", "인천시" => "Incheon",
      "대구시" => "Daegu", "제주시" => "Jeju", "남원시" => "Namwon"
    }
    city_en = city_map[@city_ko] || "Seoul"

    # 3. 서비스 실행 (새 데이터 생성)
    service = DailyPainService.new(city_en, @city_ko)
    
    if service.run_daily_process
      # [핵심] ID 기준 최신 데이터 조회 (가장 정확한 방식)
      @weather = DailyWeather.where(location: @city_ko).order(id: :desc).first
      
      # [차트용] 최근 7일 데이터 (데이터가 없어도 에러 안 나게 설정)
      @weekly_weather = DailyWeather.where(location: @city_ko).order(id: :desc).limit(7).reverse
    end
  rescue => e
    Rails.logger.error "Home Index Error: #{e.message}"
    # 에러 발생 시에도 페이지는 띄울 수 있도록 예외 처리
  end
end