require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
end

require 'rspec'
require 'rack/test'
require 'awesome_print'
require 'apicop'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end
