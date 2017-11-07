require File.expand_path '../../spec_helper.rb', __FILE__

describe "receiving a phone call", feature:true do
  let(:forwarding_number) { Faker::PhoneNumber.cell_phone }
  context "when dnb is off" do
    before(:each) do
      app.settings.app_config.set("FORWARDING_NUMBER", forwarding_number)
      app.settings.app_config.set("dnd", false)
    end

    it "should send a message" do
      expect {
        post "/receiver/message", { 'To': 'test',
                                    'From': 'Hello',
                                    'Body': 'hello there' }
      }.to change { Mgwen::FakePhone.messages.count }
    end
  end
  context "when dnb is on" do
    before(:each) do
      app.settings.app_config.set("FORWARDING_NUMBER", forwarding_number)
      app.settings.app_config.set("dnd", true)
    end

    it "should save the message" do
      expect {
        post "/receiver/message", { 'To': 'test',
                                    'From': 'Hello',
                                    'Body': 'hello there' }
      }.to change { Message.count }
    end
  end
end
