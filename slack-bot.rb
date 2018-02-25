require 'bundler/setup'
require 'slack-ruby-client'
require 'cgi/escape'
require 'pp'

TOKEN        = ENV['SLACK_BOT_TOKEN']
CHANNEL      = ENV['SLACK_CHANNEL'] || '#general'
CHANNEL_OPS  = ENV['SLACK_CHANNEL_OPS']
KEYWORD      = CGI.escapeHTML(ENV['SLACK_KEYWORD'])

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
  client.message channel: CHANNEL_OPS_ID, text: "RTM Connected: keyword=#{KEYWORD} in <##{CHANNEL_ID}>" unless CHANNEL_OPS_ID.nil? or KEYWORD.nil?
end

client.on :message do |data|
  if (not KEYWORD.empty?) and data.channel == CHANNEL_ID
    pp data
    case data.text
    when /#{KEYWORD}/ then
      client.message channel: data.channel, text: "<!channel> yo!"
    when /#{BOT_USER_ID}/ then
      client.message channel: data.channel, text: "<@#{data.user}> Hi."
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
