require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

require 'rspec'
require 'rack/test'

require 'apicop'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
