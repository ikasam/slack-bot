require 'bundler/setup'
require 'slack-ruby-client'

TOKEN        = ENV['SLACK_BOT_TOKEN']
CHANNEL      = ENV['SLACK_CHANNEL'] || '#general'
CHANNEL_OPS  = ENV['SLACK_CHANNEL_OPS']
INTERVAL     = (ENV['INTERVAL'] || 15).to_i

Slack.configure do |conf|
  conf.token = TOKEN
end

# Get IDs via Web API
client = Slack::Web::Client.new
CHANNEL_ID     = client.channels_info(channel: CHANNEL).channel.id
CHANNEL_OPS_ID = client.channels_info(channel: CHANNEL_OPS).channel.id unless CHANNEL_OPS.nil?

# RTM Connection
client = Slack::RealTime::Client.new

client.on :hello do
  BOT_USER_ID    = client.self.id
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
  client.message channel: CHANNEL_OPS_ID, text: "RTM Connected: interval=#{INTERVAL} in <##{CHANNEL_ID}>" unless CHANNEL_OPS_ID.nil? or INTERVAL.nil?
end

client.on :message do |data|
  if data.channel == CHANNEL_ID
    m = /\d+年\d+月\d+日/.match(data.text)
    reserve_day = Date.strptime(m[0], "%Y年%m月%d日")
    date_diff = (reserve_day - Date.today).to_i
    if date_diff <= INTERVAL
      client.message channel: data.channel, text: "<!channel> #{INTERVAL}日以内の予約です!"
    end
  end
end

client.on :close do |_data|
  puts "Client is about to disconnect"
end

client.on :closed do |_data|
  puts "Client has disconnected successfully!"
end

client.start!
