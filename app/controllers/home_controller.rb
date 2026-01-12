# app/controllers/home_controller.rb

def index
  @city_ko = params[:city].presence || "동탄시"
  city_map = { "동탄시"=>"Hwaseong", "서울시"=>"Seoul", "부산시"=>"Busan", "대구시"=>"Daegu", "제주시"=>"Jeju" }
  city_en = city_map[@city_ko] || "Seoul"

  service = DailyPainService.new(city_en, @city_ko)
  if service.run_daily_process
    @weather = DailyWeather.where(location: @city_ko).order(created_at: :desc).first
  end
end