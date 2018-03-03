require 'bundler/setup'
require 'slack-ruby-client'

TOKEN        = ENV['SLACK_BOT_TOKEN']
CHANNEL      = ENV['SLACK_CHANNEL'] || '#general'
CHANNEL_OPS  = ENV['SLACK_CHANNEL_OPS']
MESSAGE      = (ENV['SLACK_MESSAGE'] || 'yo!').gsub(/\\n/,"\n")

Slack.configure do |conf|
  conf.token = TOKEN
  conf.logger = Logger.new(STDOUT)
  conf.logger.level = Logger::WARN
end

# Get IDs via Web API
web_client = Slack::Web::Client.new
CHANNEL_ID     = web_client.channels_info(channel: CHANNEL).channel.id
CHANNEL_OPS_ID = web_client.channels_info(channel: CHANNEL_OPS).channel.id unless CHANNEL_OPS.nil?

def start!(web_client)
  # RTM Connection
  rtm_client = Slack::RealTime::Client.new
  
  rtm_client.on :hello do
    puts "Successfully connected, welcome '#{rtm_client.self.name}' to the '#{rtm_client.team.name}' team at https://#{rtm_client.team.domain}.slack.com."
    web_client.chat_postMessage channel: CHANNEL_OPS_ID, text: "RTM client has connected: in <##{CHANNEL_ID}>", as_user: false unless CHANNEL_OPS_ID.nil?
  end
  
  rtm_client.on :message do |data|
    if data.channel == CHANNEL_ID
      if (m = /\d+年\d+月\d+日/.match(data.text))
        reserve_day = Date.strptime(m[0], "%Y年%m月%d日")
        date_diff = (reserve_day - Date.today).to_i
        if date_diff <= 1
          web_client.chat_postMessage channel: data.channel, text: "<!channel> \n" + MESSAGE, as_user: false
        end
      end
    elsif data.channel == CHANNEL_OPS_ID
      if data.bot_id.nil?
        if (m = /restart/.match(data.text))
          rtm_client.stop!
        end
      end
    end
  end
  
  rtm_client.on :close do |_data|
    puts "Client is about to disconnect"
  end
  
  rtm_client.on :closed do |_data|
    puts "Client has disconnected successfully!"
    web_client.chat_postMessage channel: CHANNEL_OPS_ID, text: "RTM client has disconnected.", as_user: false
    start!(web_client)
  end
  
  rtm_client.start!
end

start!(web_client)
