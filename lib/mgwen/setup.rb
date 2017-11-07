require 'twilio-ruby'
require './lib/mgwen/phone'

module Mgwen
  class Setup
    def initialize
      @phone = Mgwen::Phone.new
      @client = @phone.get_client
    end

    def setup_config_items
      for config in Mgwen::Config::CONFIGURATION_ITEMS
        Mgwen::Config.register(config)
      end
    end

    def setup_development_server
      require 'ngrok/tunnel'
      options = {addr: 9292}
      options[:config] = ENV['HOME'] + '/.ngrok2/ngrok.yml'

      puts "[NGROK] tunneling at " + Ngrok::Tunnel.start(options)
      puts "[NGROK] inspector web interface listening at http://127.0.0.1:4040"
      return Ngrok::Tunnel.ngrok_url
    end

    def setup_phone_number(phone_number_sid, webhook_host)
      number = self.find_phone_number(phone_number_sid)
      number.update(sms_url: "#{webhook_host}/receiver/message",
                    voice_url: "#{webhook_host}/receiver/voice")
    end
    def setup_conversation_phone_number(phone_number_sid, webhook_host)
      number = self.find_phone_number(phone_number_sid)
      number.update(sms_url: "#{webhook_host}/receiver/conversation")
    end

    def find_phone_number(phone_number_sid)
      ret = nil
      number = @client.api.incoming_phone_numbers(phone_number_sid).fetch
      ret = number unless number.nil?
      return ret
    end
  end
end
