require 'faker'
require 'securerandom'

module Mgwen
  class FakeMessage
    def initialize(from, to, message)
      @from = from
      @to = to
      @message = message
    end
    def from
      @from
    end
    def to
      @to
    end
    def body
      @message
    end
  end

  class FakeNumber
    def initialize(number)
      @phone_number = number
      @sid = SecureRandom.uuid
    end
    def phone_number
      @phone_number
    end
    def sid
      @sid
    end
  end

  class FakePhone
    @@messages = []
    @@provisioned_numbers = []

    def initialize
    end

    def provision_phone_number(area_code, app_url)
      @phone_number = FakeNumber.new(Faker::PhoneNumber.cell_phone.to_s)
      @@provisioned_numbers << @phone_number.phone_number
      return @phone_number
    end

    def send_message(from_number, to_number, body)
      message = FakeMessage.new(from_number, to_number, body)
      @@messages.push message
    end

    def self.provisioned_numbers
      @@provisioned_numbers
    end

    def self.messages
      @@messages
    end
  end
end
