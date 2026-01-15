require 'net/http'
require 'json'
require 'ostruct'

class HomeController < ApplicationController
  def index
    @city_name = params[:city].presence || "서울"
    @city_ko = @city_name.strip
    
    # [정밀 좌표 데이터베이스]
    city_coords = {
      "서울" => {nx: 60, ny: 127}, "포항" => {nx: 102, ny: 94}, "춘천" => {nx: 73, ny: 134},
      "광주" => {nx: 58, ny: 74}, "창원" => {nx: 90, ny: 77}, "마산" => {nx: 89, ny: 76},
      "제주" => {nx: 52, ny: 38}, "서귀포" => {nx: 52, ny: 33}, "부산" => {nx: 98, ny: 76}
    }
    
    clean_name = @city_ko.gsub(/(시|군|구|도|합포구|회원구)$/, "")
    coords = city_coords[clean_name] || city_coords["서울"]

    # [시간 교정] 매시 45분 기준 데이터 갱신
    now = Time.now.in_time_zone("Seoul")
    target = now.min < 45 ? now - 1.hour : now
    base_date = target.strftime("%Y%m%d")
    base_time = target.strftime("%H00")

    service_key = "c1bf5558fa6cadc1701a4f241f2172f17c21cec2d1b7a3e7a13a12cb2c8440cb"
    url = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst"

    begin
      uri = URI(url)
      uri.query = URI.encode_www_form({
        serviceKey: service_key, pageNo: 1, numOfRows: 10, dataType: 'JSON',
        base_date: base_date, base_time: base_time, nx: coords[:nx], ny: coords[:ny]
      })
      
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)

      if data.dig("response", "header", "resultCode") == "00"
        items = data.dig("response", "body", "items", "item")
        temp = items.find { |i| i["category"] == "T1H" }&.fetch("obsrValue", "--")
        humi = items.find { |i| i["category"] == "REH" }&.fetch("obsrValue", "--")

        t_val = temp.to_f
        h_val = humi.to_f
        
        # [건강 분석 로직]
        @temp_color = t_val <= 5 ? "#3b82f6" : "#fbbf24"
        @temp_alert = t_val <= 5 ? "🚨 심혈관 주의!" : "✅ 적정 체온 유지"
        @humi_color = h_val <= 40 ? "#ef4444" : "#10b981"
        @humi_alert = h_val <= 40 ? "⚠️ 기관지 주의!" : "✅ 습도 적정"

        @weather = OpenStruct.new(
          temp: temp, humidity: humi, pressure: "1013",
          temp_color: @temp_color, temp_alert: @temp_alert,
          humi_color: @humi_color, humi_alert: @humi_alert,
          ai_content: "[AI 건강 기상 리포트]\n\n현재 #{@city_ko}의 기온은 #{temp}도, 습도는 #{humi}%입니다.\n기상청 실시간 데이터를 분석한 결과, #{@temp_alert} 상태입니다.\n\n급격한 온도 변화는 심장과 혈관에 부담을 줄 수 있으니 외출 시 보온에 유의하세요.\n건조한 날씨에는 충분한 수분 섭취가 필수입니다.\n오늘의 맞춤 건강 가이드를 통해 안전한 하루 되시길 바랍니다.\n\n© oneclipai.info"
        )
      else
        @weather = nil
      end
    rescue
      @weather = nil
    end
  end
end