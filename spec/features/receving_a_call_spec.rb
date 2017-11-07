require File.expand_path '../../spec_helper.rb', __FILE__

describe "receiving a phone call", feature:true do
  let(:forwarding_number) { Faker::PhoneNumber.cell_phone }
  context "when dnb is on" do
    let(:forwarding_number) { Faker::PhoneNumber.cell_phone }
    before(:each) do
      app.settings.app_config.set("FORWARDING_NUMBER", forwarding_number)
      app.settings.app_config.set("dnd", true)
    end
    it "should go to voicemail" do
      post "/receiver/voice", params: { }
      twilio_response = Twilio::TwiML::VoiceResponse.new do |r|
        r.say('Please leave a message after the beep!')
        r.record(max_length: '120',
                action: '/receiver/voicemail',
                method: 'post')
      end.to_s
      expect(last_response.body).to eq(twilio_response)
    end
  end

  context "when dnb is off" do
    before(:each) do
      app.settings.app_config.set("FORWARDING_NUMBER", forwarding_number)
      app.settings.app_config.set("dnd", false)
    end
    it "should dial out to the forwarding_number" do
      post "/receiver/voice", params: { }
      twilio_response = Twilio::TwiML::VoiceResponse.new do |r|
        r.dial(number: forwarding_number)
      end.to_s
      expect(last_response.body).to eq(twilio_response)
    end
    context "and without a forwarding number" do
      before(:each) do
        app.settings.app_config.set("FORWARDING_NUMBER", '')
      end
      it "should route calls to voicemail" do
        post "/receiver/voice", params: { }
        twilio_response = Twilio::TwiML::VoiceResponse.new do |r|
          r.say('Please leave a message after the beep!')
          r.record(max_length: '120',
                  action: '/receiver/voicemail',
                  method: 'post')
        end.to_s
        expect(last_response.body).to eq(twilio_response)
      end
    end
  end
end
