require 'spec_helper.rb'

describe APICop::OAuth2::Client::Error do
  let :error do
    {
      :error             => :invalid_request,
      :error_description => 'Include invalid parameters',
      :error_uri         => 'http://server.example.com/error/invalid_request'
    }
  end
  subject do
    APICop::OAuth2::Client::Error.new 400, error
  end

  context 'status' do
    it { expect(subject.status).to eq 400 }
  end
  context 'message' do
    it { expect(subject.message).to eq error[:error_description] }
  end
  context 'response' do
    it { expect(subject.response).to eq error }
  end
end
