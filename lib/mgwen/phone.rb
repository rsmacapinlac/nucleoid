require 'twilio-ruby'

module Mgwen
  class Phone
    cattr_accessor :client
    def initialize
      @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
    end

    def get_client
      @client
    end

    def send_message(from, to, body)
      @client.messages.create(from: from, to: to, body: body)
    end

    def find_phone_number(sid)
      @client.api.incoming_phone_numbers(sid).fetch
    end

    def provision_phone_number(area_code, app_public_host)
      numbers = @client.api.available_phone_numbers('CA').local.list(voice_enabled: 'false',
                                                                    sms_enabled: 'true',
                                                                    mms_enabled: 'true',
                                                                    area_code: area_code)


      phone_number = numbers[0].phone_number
      number = @client.incoming_phone_numbers.create(phone_number: phone_number)
      number.update(sms_url: "#{app_public_host}/receiver/conversation")
      return number
    end
  end
end
