require 'rack'
require 'multi_json'
require 'httpclient'
require 'logger'
require 'active_support'
require 'active_support/core_ext'
require 'attr_required'
require 'attr_optional'

module APICop
  module OAuth2

    VERSION = APICop::VERSION

    def self.logger
      @@logger
    end
    def self.logger=(logger)
      @@logger = logger
    end
    self.logger = ::Logger.new(STDOUT)
    self.logger.progname = 'APICop::OAuth2'

    def self.debugging?
      @@debugging
    end
    def self.debugging=(boolean)
      @@debugging = boolean
    end
    def self.debug!
      self.debugging = true
    end
    def self.debug(&block)
      original = self.debugging?
      self.debugging = true
      yield
    ensure
      self.debugging = original
    end
    self.debugging = false

    def self.http_client(agent_name = "APICop::OAuth2 (#{VERSION})", &local_http_config)
      _http_client_ = HTTPClient.new(
        :agent_name => agent_name
      )
      http_config.try(:call, _http_client_)
      local_http_config.try(:call, _http_client_) unless local_http_config.nil?
      _http_client_.request_filter << Debugger::RequestFilter.new if debugging?
      _http_client_
    end

    def self.http_config(&block)
      @@http_config ||= block
    end

    def self.reset_http_config!
      @@http_config = nil
    end

  end
end

require 'apicop/oauth2/util'
require 'apicop/oauth2/server'
require 'apicop/oauth2/client'
require 'apicop/oauth2/access_token'
require 'apicop/oauth2/debugger'
