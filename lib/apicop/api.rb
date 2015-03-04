require 'apicop/api/token'

module APICop
  module API
    class Root < Grape::API
      format :json
      default_format :json

      mount Token
    end
  end
end
