require 'spec_helper.rb'

describe APICop::OAuth2::Client::Grant::ClientCredentials do
  context '#as_json' do
    it { expect(subject.as_json).to eq({ :grant_type => :client_credentials }) }
  end
end
