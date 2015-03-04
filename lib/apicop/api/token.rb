module APICop
  module API
    class Token < Grape::API
      post '/oauth/token' do
        env
      end
    end
  end
end
