require 'net/http'
require 'json'
require 'ostruct'

class HomeController < ApplicationController
  def index
    @city_name = params[:city].presence || "서울"
    @city_ko = @city_name.strip
    
    city_coords = {
      "서울" => {nx: 60, ny: 127}, "포항" => {nx: 102, ny: 94}, "춘천" => {nx: 73, ny: 134},
      "광주" => {nx: 58, ny: 74}, "창원" => {nx: 90, ny: 77}, "마산" => {nx: 89, ny: 76},
      "제주" => {nx: 52, ny: 38}, "서귀포" => {nx: 52, ny: 33}, "부산" => {nx: 98, ny: 76}
    }
    
    clean_name = @city_ko.gsub(/(시|군|구|도|합포구|회원구)$/, "")
    coords = city_coords[clean_name] || city_coords["서울"]

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

        @weather = OpenStruct.new(
          temp: temp, humidity: humi,
          temp_color: temp.to_f <= 5 ? "#3b82f6" : "#fbbf24",
          temp_alert: temp.to_f <= 5 ? "🚨 심혈관 주의!" : "✅ 적정 체온 유지",
          humi_color: humi.to_f <= 40 ? "#ef4444" : "#10b981",
          humi_alert: humi.to_f <= 40 ? "⚠️ 기관지 주의!" : "✅ 습도 적정",
          ai_content: "📍 [#{@city_ko} 실시간 건강 예보]\n\n" \
                      "1. 현재 기온은 #{temp}도이며 습도는 #{humi}%로 관측됩니다.\n" \
                      "2. 기상청 데이터를 분석한 결과, 현재 #{@temp_alert} 단계입니다.\n" \
                      "3. 갑작스러운 기온 변화는 심장과 혈관에 큰 부담을 줄 수 있습니다.\n" \
                      "4. 특히 노약자나 고혈압 환자분들은 외출 시 보온에 각별히 유의하세요.\n" \
                      "5. 건조한 공기는 기관지 점막을 약하게 하니 충분한 수분을 섭취하십시오.\n" \
                      "6. 실시간 맞춤형 가이드로 건강하고 안전한 하루 되시길 바랍니다.\n\n" \
                      "© oneclipai.info"
        )
      else
        @weather = nil
      end
    rescue
      @weather = nil
    end
  end
end