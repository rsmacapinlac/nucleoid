require './lib/mgwen/phone'
require 'phony'

module Mgwen
  class Conversation
    def initialize(config)
      @config = config
    end

    def find_or_create(from_number)
      available_sessions = Session.where(from_number: from_number)

      # use an existing one
      unless available_sessions.count == 0
        conversation = available_sessions.first
        return conversation.phone_number
      end

      # try to find one that has expired
      expired_sessions = Session.where("? > updated_at", 2.hours.ago).limit(1)
      unless expired_sessions.count == 0
        session = expired_sessions.first
        Conversation.start_conversation_with_number(session, from_number)
        return conversation.phone_number
      end

      # can I create one?
      total_sessions = Session.all.count
      if total_sessions < 3
        forwarding_number = @config.get("FORWARDING_NUMBER")
        area_code = Phony.split(Phony.normalize(forwarding_number))[1]

        public_host = @config.get("APP_PUBLIC_HOST")

        Conversation.create_new_number_and_conversation(from_number, area_code, public_host)
        available_sessions.reload
        session = available_sessions.first
      else
        # reuse the oldest one
        sessions = Session.all.order(updated_at: :desc)
        session = sessions.last
      end

      Conversation.start_conversation_with_number(session, from_number)
      return session.phone_number
    end

    def self.start_conversation_with_number(session, from_number)
      Session.transaction do
        phone = Mgwen::Phone.new
        forwarder_number = Mgwen::Config.instance.get("FORWARDING_NUMBER")
        phone.send_message(session.phone_number,
                           forwarder_number,
                           "Starting conversation with #{from_number}")
        session.from_number = from_number
        session.save
      end
    end

    def self.create_new_number_and_conversation(from_number, in_area_code, app_public_host)
      Session.transaction do
        phone = Mgwen::Phone.new
        session_phone_number = phone.provision_phone_number(in_area_code, app_public_host)
        Session.new(phone_number: session_phone_number.phone_number,
                    phone_number_sid: session_phone_number.sid,
                    from_number: from_number).save
      end
    end

    def self.initialize_numbers(public_host)
      setup = Mgwen::Setup.new
      for session in Session.all
        setup.setup_conversation_phone_number(session.phone_number_sid, public_host)
      end
    end
  end
end
