module Warden
  module OAuth2
    class FailureApp
      def self.call(env)
        new.call(env)
      end

      def call(env)
        warden = env['warden']
        strategy = warden.winning_strategy

        body = '{"error":"' + strategy.message.to_s + '"}'
        status = begin strategy.error_status rescue 401 end
        headers = { 'Content-Type' => 'application/json' }

        headers['X-Accepted-OAuth-Scopes'] = (strategy.scope || :public).to_s

        [status, headers, [body]]
      end
    end
  end
end
