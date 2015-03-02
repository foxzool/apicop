module APICop
  module OAuth2
    module Server
      class Token
        class ClientCredentials < Abstract::Handler
          def call(env)
            @request  = Request.new(env)
            @response = Token::Response.new(request)
            super
          end

          class Request < Token::Request
            def initialize(env)
              super
              @grant_type = :client_credentials
              attr_missing!
            end
          end
        end
      end
    end
  end
end
