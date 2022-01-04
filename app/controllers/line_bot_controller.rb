class LineBotController < ApplicationController
  protect_from_forgery except: [:callback]

  require 'line/bot'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body,signature)
      return head :bad_request
    end
    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          app_id = ENV["OPEN_WEATHER_MAP_APPID"]
          url = "http://api.openweathermap.org/data/2.5/forecast?q=Tokyo&appid=#{app_id}&units=metric&mode=xml"
         # XMLをパースしていく
          xml = open( url ).read.toutf8
          doc = REXML::Document.new(xml)
          xpath = 'weatherdata/forecast/time[1]/'
          weather = doc.elements[xpath + 'symbol'].attributes['name']
          temp = doc.elements[xpath + 'temperature'].attributes['value']
          humidity = doc.elements[xpath + 'humidity'].attributes['value']
          case event.message['text']
          when  /.*(現在の予報).*/
            if weather = /.*(clear sky|few clouds|scattered clouds|broken clouds|overcast clouds).*/ && temp >= 25.to_s && humidity >= 65.to_s
              push = "一日中暑く、汗や湿気でくせがでやすいです。\nスタイリングもそうですが発汗対策をしっかり行いましょう！"
            elsif weather = /.*(clear sky|few clouds|scattered clouds|broken clouds|overcast clouds).*/ && temp >= 25.to_s && humidity < 65.to_s
              push =  "湿度はそこまで高くありませんが、一日中気温が高いため汗でくせが出てしまいます。\n発汗対策をしっかり行いましょう!"
            elsif weather = /.*(clear sky|few clouds|scattered clouds|broken clouds|overcast clouds).*/ && temp < 25.to_s && humidity >= 65.to_s
              push = "湿気が多いのでくせが出やすくスタイリングが崩れやすいです。\n外出する際はアイロンとヘアスプレーでしっかりスタイリングしましょう!"
            elsif weather = /.*(clear sky|few clouds|scattered clouds|broken clouds|overcast clouds).*/ && temp < 25.to_s && humidity < 65.to_s && humidity > 50.to_s
              push =  "今日は髪のうねりが出にくく髪がまとまりやすい天気です！\n思いっきりスタイリングを楽しみましょう。"
            elsif weather = /.*(clear sky|few clouds|scattered clouds|broken clouds|overcast clouds).*/ && temp < 25.to_s && humidity <= 50.to_s
              push = "くせは気になりませんが湿度が低く乾燥や静電気で髪の毛が膨張したり摩擦でキューティクルが剥がれて髪の毛がパサパサになりやすいです。\nスタイリングする際は保湿を心がけましょう。"
            elsif weather = /.*(rain|thunderstorm|drizzle).*/ && temp >= 25.to_s && humidity >= 65.to_s
              push = "汗、雨、湿気で髪がまとまらず、アイロンやヘアスプレーを使ってもすぐ崩れてしまうかもしれません。\nこういう日が続く場合は思い切って縮毛矯正をかけるのもいいいいかも。"
            elsif weather = /.*(rain|thunderstorm|drizzle).*/ && temp >= 25.to_s && humidity < 65.to_s 
              push = "湿気は気になりませんが、汗と雨で前髪などが崩れるかもしれません。\n発汗対策もそうですが、外出する際はアイロンとヘアスプレーでしっかりスタイリングしましょう!"
            elsif weather = /.*(rain|thunderstorm|drizzle).*/ && temp < 25.to_s && humidity >= 65.to_s
              push = "雨、湿気で髪がまとまらず、アイロンやヘアスプレーを使ってもすぐ崩れてしまうかもしれません。\nこういう日が続く場合は思い切って縮毛矯正をかけるのもいいいいかも。"
            elsif weather = /.*(rain|thunderstorm|drizzle).*/ && temp < 25.to_s && humidity < 65.to_s && humidity > 50.to_s
              push =  "湿気はそこまで気になりませんが雨に当たってヘアスタイルが崩れないようにアイロンとヘアスプレーでしっかりスタイリングしましょう!"
            elsif weather =  /.*(rain|thunderstorm|drizzle).*/ && temp < 25.to_s && humidity <= 50.to_s
              push = "乾燥と雨で髪がまとまらない可能性が高いです。\nスタイリングと保湿をしっかり行いましょう"
            elsif weather =  /.*(snow).*/
              push = "現在地の天気は雪です\u{2744}\n\n現在の気温は#{now_temp}℃です\u{1F321}"
            elsif weather = /.*(fog|mist|Haze).*/
              push = "現在地では霧が発生しています\u{1F32B}\n\n現在の気温は#{now_temp}℃です\u{1F321}"
            else
              push = "現在地では何かが発生していますが、\nご自身でお確かめください。\u{1F605}\n\n現在の気温は#{now_temp}℃です\u{1F321}"
            end
          end
        end
          message = {
            type: 'text',
            text: push
          }
          client.reply_message(event['replyToken'], message)
      end
    end
    head :ok
  end

  private
 
     def client
       @client ||= Line::Bot::Client.new { |config|
         config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
         config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
       }
     end
end
