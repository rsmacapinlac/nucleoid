require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require 'twilio-ruby'
require './lib/mgwen'
require './lib/mgwen/setup'
require './lib/mgwen/conversation'
require './lib/mgwen/config'
require './lib/mgwen/rule'
require './lib/mgwen/phone'

current_dir = Dir.pwd

# load models
Dir["#{current_dir}/models/*.rb"].each { |file| require file }
# load initializers

set :server, 'thin'

configure do
  setup = Mgwen::Setup.new
  setup.setup_config_items

  # get configuration
  set app_config: Mgwen::Config.instance
  settings.app_config.get_or_set("dnd", false)

  phone = Mgwen::Phone.new
  phone_number_sid = ENV.fetch('PHONE_NUMBER_SID', nil)
  unless phone_number_sid.nil?
    number = phone.find_phone_number(phone_number_sid)
    settings.app_config.set "NUCLEOID_NUMBER", number.phone_number
  end
end

configure :development do
  @setup = Mgwen::Setup.new
  public_host = @setup.setup_development_server

  config = Mgwen::Config.instance
  config.set "APP_PUBLIC_HOST", public_host

  Mgwen::Conversation.initialize_numbers(public_host)
  @setup.setup_phone_number(ENV.fetch('PHONE_NUMBER_SID'), public_host)
end

post '/receiver/voice' do
  content_type 'text/xml'
  rules = Mgwen::Rule.new(Mgwen::Config.instance)
  rules.process_voice
end

post '/receiver/voicemail' do
  Mgwen::Rule.save_voicemail("New Voicemail message from #{params['Caller']}",
               "Message length: #{params['RecordingDuration']}s",
               params['RecordingUrl'] + '.mp3')
end

post '/receiver/conversation' do
  phone = Mgwen::Phone.new
  # should only accept incoming from a user's forwarding phone number
  if phone.is_forwarder?(params['From'])
    # find the conversation that this is assigned to
    conversation = Conversation.find_by(session_phone_number: params['To'])
    # send a message to the conversations' from_number from the gmwn_number
    unless conversation.nil?
      phone.send_message(settings.mgwen_number,
                         conversation.from_number,
                         params['Body'])
    end
  end
end

post '/receiver/message' do
  content_type 'text/xml'
  rules = Mgwen::Rule.new(Mgwen::Config.instance)
  rules.process_message(params)
end

get '/configs.json' do
  content_type :json
  Mgwen::Config.instance.to_json
end

post '/register' do
  Mgwen::Config.register(params['name'])
end

post '/config/:name' do
  config = Mgwen::Config.instance
  config.set(params['name'], params['value'])
end

