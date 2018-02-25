require 'bundler/setup'
require 'slack-ruby-client'

TOKEN        = ENV['SLACK_BOT_TOKEN']
CHANNEL      = ENV['SLACK_CHANNEL'] || 'general'
CHANNEL_OPS  = ENV['SLACK_CHANNEL_OPS'] || 'bot-test'
BOT_USERNAME = ENV['SLACK_BOT_USERNAME']
KEYWORD      = ENV['KEYWORD']

Slack.configure do |conf|
  conf.token = TOKEN
end

# Get IDs via Web API
client = Slack::Web::Client.new
CHANNEL_ID     = client.channels_info(channel: '#'+CHANNEL).channel.id
CHANNEL_OPS_ID = client.channels_info(channel: '#'+CHANNEL_OPS).channel.id
BOT_USER_ID    = client.users_info(user: '@'+BOT_USERNAME).user.id

# RTM Connection
client = Slack::RealTime::Client.new

client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
  client.message channel: CHANNEL_OPS_ID, text: "RTM Connected: keyword=#{KEYWORD} in <##{CHANNEL_ID}|#{CHANNEL}>"
end

client.on :message do |data|
  if data.channel == CHANNEL_ID
    case data.text
    when /#{KEYWORD}/ then
      client.message channel: data.channel, text: "<!channel> yo!"
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
