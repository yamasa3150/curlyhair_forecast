namespace :message do
  desc "時間になったらメッセージが届くタスク"
  task message_send: :environment do
    require 'line/bot'
    require 'open-uri'
    require 'kconv'
    require 'rexml/document'

    client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }

    app_id = ENV["OPEN_WEATHER_MAP_APPID"]
    url = "http://api.openweathermap.org/data/2.5/forecast?q=Tokyo&appid=#{app_id}&units=metric&mode=xml"
    xml = open( url ).read.toutf8
    doc = REXML::Document.new(xml)
    xpath = 'weatherdata/forecast/time[1]/'
    weather = doc.elements[xpath + 'symbol'].attributes['name']
    temp = doc.elements[xpath + 'temperature'].attributes['value']
    humidity = doc.elements[xpath + 'humidity'].attributes['value']
    user = User.find_by(line_user_id: ENV["LINE_CHANNEL_USER_ID"])
    push_time = user.setting.push_time.to_s(:time)
    if push_time == Time.now.to_s(:time)
      if weather = /.*(clear sky|few clouds|scattered clouds|broken clouds|overcast clouds).*/ && temp.to_i >= 25 && humidity.to_i >= 65
        push = "一日中暑く、汗や湿気でくせがでやすいです。\nスタイリングもそうですが発汗対策をしっかり行いましょう！"
      elsif weather = /.*(clear sky|few clouds|scattered clouds|broken clouds|overcast clouds).*/ && temp.to_i >= 25 && humidity.to_i < 65
        push =  "湿度はそこまで高くありませんが、一日中気温が高いため汗でくせが出てしまいます。\n発汗対策をしっかり行いましょう!"
      elsif weather = /.*(clear sky|few clouds|scattered clouds|broken clouds|overcast clouds).*/ && temp.to_i < 25 && humidity.to_i >= 65
        push = "湿気が多いのでくせが出やすくスタイリングが崩れやすいです。\n外出する際はアイロンとヘアスプレーでしっかりスタイリングしましょう!"
      elsif weather = /.*(clear sky|few clouds|scattered clouds|broken clouds|overcast clouds).*/ && temp.to_i < 25 && humidity.to_i < 65 && humidity.to_i > 50
        push =  "今日は髪のうねりが出にくく髪がまとまりやすい天気です！\n思いっきりスタイリングを楽しみましょう。"
      elsif weather = /.*(clear sky|few clouds|scattered clouds|broken clouds|overcast clouds).*/ && temp.to_i < 25 && humidity.to_i <= 50
        push = "くせは気になりませんが湿度が低く乾燥や静電気で髪の毛が膨張したり摩擦でキューティクルが剥がれて髪の毛がパサパサになりやすいです。\nスタイリングする際は保湿を心がけましょう。"
      elsif weather = /.*(rain|thunderstorm|drizzle).*/ && temp.to_i >= 25 && humidity.to_i >= 65
        push = "汗、雨、湿気で髪がまとまらず、アイロンやヘアスプレーを使ってもすぐ崩れてしまうかもしれません。\nこういう日が続く場合は思い切って縮毛矯正をかけるのもいいいいかも。"
      elsif weather = /.*(rain|thunderstorm|drizzle).*/ && temp.to_i >= 25 && humidity.to_i < 65
        push = "湿気は気になりませんが、汗と雨で前髪などが崩れるかもしれません。\n発汗対策もそうですが、外出する際はアイロンとヘアスプレーでしっかりスタイリングしましょう!"
      elsif weather = /.*(rain|thunderstorm|drizzle).*/ && temp.to_i < 25 && humidity.to_i >= 65
        push = "雨、湿気で髪がまとまらず、アイロンやヘアスプレーを使ってもすぐ崩れてしまうかもしれません。\nこういう日が続く場合は思い切って縮毛矯正をかけるのもいいいいかも。"
      elsif weather = /.*(rain|thunderstorm|drizzle).*/ && temp.to_i < 25 && humidity.to_i < 65 && humidity.to_i > 50
        push =  "湿気はそこまで気になりませんが雨に当たってヘアスタイルが崩れないようにアイロンとヘアスプレーでしっかりスタイリングしましょう!"
      elsif weather =  /.*(rain|thunderstorm|drizzle).*/ && temp.to_i < 25 && humidity.to_i <= 50
        push = "乾燥と雨で髪がまとまらない可能性が高いです。\nスタイリングと保湿をしっかり行いましょう"
      else
        push = "現在地では何かが発生していますが、\nご自身でお確かめください。\u{1F605}\n\n現在の気温は#{temp}℃です\u{1F321}"
      end
    end

    message = {
      type: 'text',
      text: push
    }
    response = client.push_message(ENV["LINE_CHANNEL_USER_ID"], message)
    p response
  end
end
