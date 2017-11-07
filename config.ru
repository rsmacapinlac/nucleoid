require 'rubygems'
require 'bundler'
require 'dotenv'

Dotenv.load
Bundler.require

require './app'

run Sinatra::Application
