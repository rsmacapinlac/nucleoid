require 'rack/test'
require 'rspec'
require 'faker'
require 'mail'
require "capybara/rspec"
require 'pony'
require 'email_spec'

require 'dotenv'
Dotenv.load

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../app.rb', __FILE__
require File.expand_path '../../lib/mgwen/fake_phone.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

set :environment, :test

module RackSpecHelpers
  include Rack::Test::Methods
  attr_accessor :app
end

RSpec.configure do |config|
  config.include EmailSpec::Helpers, feature: true
  config.include EmailSpec::Matchers, feature: true
  config.before :each, feature: true do
    reset_mailer
  end
  config.include Capybara::DSL, feature: true
  config.include Capybara::RSpecMatchers, feature: true
  config.include RackSpecHelpers, feature: true
  config.before feature: true do
    self.app = Sinatra::Application
  end
  config.include Rack::Test::Methods
  config.include RSpecMixin
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:each) do
    stub_const("Mgwen::Phone", Mgwen::FakePhone)
  end
end
