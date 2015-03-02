require 'spec_helper.rb'

describe APICop::OAuth2::Server::Token::AuthorizationCode do
  let(:request) { Rack::MockRequest.new app }
  let(:app) do
    APICop::OAuth2::Server::Token.new do |request, response|
      response.access_token = APICop::OAuth2::AccessToken::Bearer.new(:access_token => 'access_token')
    end
  end
  let(:params) do
    {
      :grant_type => 'authorization_code',
      :client_id => 'client_id',
      :code => 'authorization_code',
      :redirect_uri => 'http://client.example.com/callback'
    }
  end
  let(:response) { request.post('/', :params => params) }
  subject { response }

  context 'status' do
    it { expect(subject.status).to eq 200 }
  end
  context 'content_type' do
    it { expect(subject.content_type).to eq 'application/json' }
  end
  context 'body' do
    it { expect(subject.body).to include '"access_token":"access_token"' }
    it { expect(subject.body).to include '"token_type":"bearer"' }
  end

  it 'should prevent to be cached' do
    expect(subject.header['Cache-Control']).to eq 'no-store'
    expect(subject.header['Pragma']).to eq 'no-cache'
  end

  [:code].each do |required|
    context "when #{required} is missing" do
      before do
        params.delete_if do |key, value|
          key == required
        end
      end

      context 'status' do
        it { expect(subject.status).to eq 400 }
      end
      context 'content_type' do
        it { expect(subject.content_type).to eq 'application/json' }
      end
      context 'body' do
        it { expect(subject.body).to include '"error":"invalid_request"' }
      end
    end
  end
end
