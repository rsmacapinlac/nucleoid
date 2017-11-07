require 'mail'
require 'open-uri'
require './lib/mgwen/phone'
require './lib/mgwen/config'

module Mgwen
  class Rule
    def initialize(config)
      @config = config
    end
    def process_voice
      dnd = @config.get("dnd").to_s
      forwarder_number = @config.get("FORWARDING_NUMBER")
      Twilio::TwiML::VoiceResponse.new do |r|
        if dnd == "false" and (!forwarder_number.empty?)
          r.dial(number: forwarder_number)
        else
          r.say('Please leave a message after the beep!')
          r.record(max_length: '120',
                  action: '/receiver/voicemail',
                  method: 'post')
        end
      end.to_s
    end

    def process_message(params)
      dnd = @config.get("dnd").to_s
      forwarder_number = @config.get("FORWARDING_NUMBER")
      if dnd == "false" and (!forwarder_number.empty?)
        conversation = Conversation.new(Mgwen::Config.instance)
        conversation_phone_number = conversation.find_or_create(params['From'])

        phone = Mgwen::Phone.new
        phone.send_message(conversation_phone_number,
                           forwarder_number,
                           params['Body'])
      else
        Message.new(
          from: params['From'],
          to:   params['To'],
          body: params['Body']
        ).save
      end

      return Twilio::TwiML::VoiceResponse.new do |r|
      end.to_s
    end

    def self.send_unread_messages
      Message.transaction do
        msg = ""
        for m in Message.all
          msg += "Received: #{m.created_at}\n"
          msg += "Msg: #{m.body}\n"
          msg += "From: #{m.from}\n\n"

        end
        self.send_email("Received messages while on DND", msg)
        Message.delete_all
      end
    end

    def self.save_voicemail(subject, message, file_url)
      self.send_email(subject, message, file_url)

      Twilio::TwiML::VoiceResponse.new do |r|
        r.say "Thank you for calling. Bye!"
        r.hangup
      end.to_s
    end

    private

    def self.send_email(subject, message, attachment_url = nil)
      Mail.defaults do
        delivery_method :smtp,  {
          address: 'smtp.sendgrid.net',
          port: '587',
          user_name: ENV['SENDGRID_USERNAME'],
          password: ENV['SENDGRID_PASSWORD'],
          authentication: 'plain',
          enable_starttls_auto: true
        }
      end

      Mail.deliver do
        from    'nucleoid@something.com'
        to      Mgwen::Config.instance.get("EMAIL_ADDRESS")
        body    message
        subject subject
        unless attachment_url.nil?
          add_file filename: 'message.mp3', content: open(attachment_url) { |f| f.read }
        end
      end
    end
  end
end
