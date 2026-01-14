class HomeController < ApplicationController
  def index
    raw_city = params[:city].present? ? params[:city].strip : '서울'
    @city_input = raw_city.end_with?('시', '군', '구') ? raw_city : "#{raw_city}시"
    @weekly_data = DailyWeather.where(location: @city_input)
                           .order(created_at: :desc)
                           .limit(7)
                           .reverse

# 자바스크립트에서 쓸 수 있게 날짜와 수치만 배열로 추출합니다.
@chart_labels = @weekly_data.map { |w| w.created_at.strftime("%m/%d %H:%M") }
@chart_values = @weekly_data.map { |w| w.pressure }
    # [체크] 여기에 검색하려는 도시들의 영문명을 추가하세요.
    city_map = { 
      "서울시" => "Seoul", "원주시" => "Wonju", "구미시" => "Gumi", 
      "춘천시" => "Chuncheon", "강릉시" => "Gangneung", "부산시" => "Busan" 
    }
    @city_en = city_map[@city_input] || "Seoul"

    @weather = DailyWeather.where(location: @city_input).last

    if @weather.nil? || @weather.created_at < 10.minutes.ago
      begin
        service = DailyPainService.new(@city_en, @city_input)
        if service.run_daily_process
          @weather = DailyWeather.where(location: @city_input).last
        end
      rescue => e
        logger.error "에러 발생: #{e.message}"
      end
    end

    @weekly_data = DailyWeather.where(location: @city_input).order(created_at: :desc).limit(7).reverse
  end
end