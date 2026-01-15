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
      "제주" => {nx: 52, ny: 38}, "서귀포" => {nx: 52, ny: 33}
    }
    
    clean_name = @city_ko.gsub(/(시|군|구|도|합포구|회원구)$/, "")
    coords = city_coords[clean_name] || city_coords["서울"]

    # [중요] 매번 새로운 시간을 계산하도록 로직 고정
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
      
      # [진단 코드] 터미널에 요청 주소를 찍어봅니다. (직접 클릭해서 확인 가능)
      puts "▶ 기상청 요청 URL: #{uri}"

      response = Net::HTTP.get(uri)
      data = JSON.parse(response)
      
      # [진단 코드] 기상청의 실제 응답을 터미널에 출력합니다.
      puts "▶ 기상청 응답 데이터: #{data.inspect}"

      if data.dig("response", "header", "resultCode") == "00"
        items = data.dig("response", "body", "items", "item")
        
        # 값을 못 찾으면 기본값 6.2 대신 "데이터없음"으로 표시하게 변경
        temp = items.find { |i| i["category"] == "T1H" }&.fetch("obsrValue", "데이터없음")
        humi = items.find { |i| i["category"] == "REH" }&.fetch("obsrValue", "데이터없음")

        @weather = OpenStruct.new(
          temp: temp, humidity: humi, pressure: "1013",
          temp_color: temp == "데이터없음" ? "#ccc" : (temp.to_f <= 5 ? "#3b82f6" : "#fbbf24"),
          temp_alert: temp == "데이터없음" ? "데이터 확인 중" : (temp.to_f <= 5 ? "🚨 심혈관 주의!" : "✅ 적정 체온 유지"),
          ai_content: "현재 #{@city_ko} 기온은 #{temp}도입니다.\n터미널 로그를 통해 실시간 데이터 수신 여부를 확인하세요."
        )
      else
        error_msg = data.dig("response", "header", "resultMsg")
        puts "▶ API 호출 실패 사유: #{error_msg}"
        @weather = OpenStruct.new(temp: "ERR", ai_content: "기상청 에러: #{error_msg}")
      end
    rescue => e
      puts "▶ 시스템 오류 발생: #{e.message}"
      @weather = OpenStruct.new(temp: "ERR", ai_content: "시스템 오류: #{e.message}")
    end
  end
end