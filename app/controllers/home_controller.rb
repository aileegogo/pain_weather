# app/controllers/home_controller.rb

def index
  @city_ko = params[:city].presence || "동탄시"
  # ... (기존 매핑 로직 그대로 유지) ...

  service = DailyPainService.new(city_en, @city_ko)
  if service.run_daily_process
    # 엔진이 성공했을 때만 데이터를 가져오므로 에러가 날 확률이 극히 낮습니다.
    @weather = DailyWeather.where(location: @city_ko).order(id: :desc).first
    @weekly_weather = DailyWeather.where(location: @city_ko).order(id: :desc).limit(7).reverse
  end
end