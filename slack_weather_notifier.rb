require 'json'
require 'open-uri'
# require 'date'
require 'slack-notifier'

def get_temperature_str(weather, maxmin)
  # TODO: simply map both maxmin and return Hash
  temperature = weather['temperature'][maxmin]

  if temperature.nil?
    '---'
  else
    "#{temperature['celsius']}℃"
  end
end

def get_attachments_for(date, link)
  min     = get_temperature_str date, 'min'
  max     = get_temperature_str date, 'max'

  title   = "#{date['dateLabel']}の天気 『#{date['telop']}』"
  text    = "最低気温 #{min}\n最高気温 #{max}\n#{date['date']}"

  {
    fallback: title + text,
    title: title,
    title_link: link,
    text: text,
    image_url: date['image']['url'],
    color: '#7CD197'
  }
end

def post_weather(date)
  # Tokyo
  uri = 'http://weather.livedoor.com/forecast/webservice/json/v1?city=130010'

  res         = JSON.load(open(uri).read)
  title       = res['title']
  # provider    = res['copyright']['provider'].first['name']
  # description = res['description']['text'].delete("\n")
  link        = res['link']

  if date == 'today'
    day = res['forecasts'][0]
  elsif date == 'tomorrow'
    day = res['forecasts'][1]
  else
    fail
  end

  # source = {
  #   title: title,
  #   title_link: link,
  #   text: 'livedoor天気情報'
  # }

  message = "*<#{link}|#{title}>* by livedoor天気情報"
  forecast = get_attachments_for day, link

  slack = Slack::Notifier.new(
    ENV['SLACK_WEBHOOK_PR'],
    channel: '#general',
    username: 'otenki'
  )
  slack.ping message, icon_url: day['image']['url'], attachments: [forecast]
end

# MAIN

# if time
#   post_weather(today, today_forecast)
# else
#   post_weather(tomorrow, tomorrow_forecast)
# end

# TODO: if clause by date needed
# post_weather 'today'
post_weather ARGV[0]
