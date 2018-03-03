require 'bundler/setup'
require 'slack-ruby-client'
require 'cgi/escape'

TOKEN        = ENV['SLACK_BOT_TOKEN']
CHANNEL      = ENV['SLACK_CHANNEL'] || '#general'
CHANNEL_OPS  = ENV['SLACK_CHANNEL_OPS']
KEYWORD      = CGI.escapeHTML(ENV['SLACK_KEYWORD'])

Slack.configure do |conf|
  conf.token = TOKEN
end

# Get IDs via Web API
WEB_CLIENT = Slack::Web::Client.new
CHANNEL_ID     = WEB_CLIENT.channels_info(channel: CHANNEL).channel.id
CHANNEL_OPS_ID = WEB_CLIENT.channels_info(channel: CHANNEL_OPS).channel.id unless CHANNEL_OPS.nil?

def start!
  # RTM Connection
  client = Slack::RealTime::Client.new
  
  client.on :hello do
    @bot_user_id = client.self.id
    puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
    WEB_CLIENT.chat_postMessage channel: CHANNEL_OPS_ID, text: "RTM Connected: keyword=#{KEYWORD} in <##{CHANNEL_ID}>", as_user: false unless CHANNEL_OPS_ID.nil? or KEYWORD.nil?
  end
  
  client.on :message do |data|
    if (not KEYWORD.empty?) and data.channel == CHANNEL_ID
      case data.text
      when /#{KEYWORD}/ then
        WEB_CLIENT.chat_postMessage channel: data.channel, text: "<!channel> yo!", as_user: false
      when /#{@bot_user_id}/ then
        WEB_CLIENT.chat_postMessage channel: data.channel, text: "<@#{data.user}> Hi.", as_user: false
      end
    end
  end
  
  client.on :close do |_data|
    puts "Client is about to disconnect"
  end
  
  client.on :closed do |_data|
    puts "Client has disconnected successfully!"
    start!
  end

  client.start!
end

start!
