require File.expand_path '../../spec_helper.rb', __FILE__

context "receiving a conversation message", feature:true do
  let(:friend_phone_number) { Faker::PhoneNumber.cell_phone }
  let(:masked_phone_number) { Faker::PhoneNumber.cell_phone }
  let(:nucleoid_phone_number) { Faker::PhoneNumber.cell_phone }
  let(:forwarding_phone_number) { Faker::PhoneNumber.cell_phone }
  let(:body) { Faker::Lorem.sentence }
  before do
    Session.create(phone_number: masked_phone_number,
                   from_number: friend_phone_number).save

    app.settings.app_config.set("NUCLEOID_NUMBER", nucleoid_phone_number)
    app.settings.app_config.set("FORWARDING_NUMBER", forwarding_phone_number)
    app.settings.app_config.set("dnd", false)
  end
  it "should send a message to the friend" do
    post "/receiver/conversation", { 'To': masked_phone_number,
                                     'From': forwarding_phone_number,
                                     'Body': body }

    message = Mgwen::FakePhone.messages.last
    expect(message.to).to eql(friend_phone_number)
    expect(message.from).to eql(nucleoid_phone_number)
    expect(message.body).to eql(body)
  end
  it 'should send a message to the forwarding number' do
    post "/receiver/message", { 'To': nucleoid_phone_number,
                                'From': friend_phone_number,
                                'Body': body }
    message = Mgwen::FakePhone.messages.last
    expect(message.to).to eql(forwarding_phone_number)
    expect(message.from).to eql(masked_phone_number)
    expect(message.body).to eql(body)
  end
end
