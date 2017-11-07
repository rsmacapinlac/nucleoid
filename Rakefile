require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'dotenv/tasks'
require 'rspec/core'
require 'rspec/core/rake_task'
# require './app'

task :default => [:spec]

desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec)
