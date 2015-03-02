require 'spec_helper.rb'

describe APICop::OAuth2::Server::Token::Password do
  let(:request) { Rack::MockRequest.new app }
  let(:app) do
    APICop::OAuth2::Server::Token.new do |request, response|
      response.access_token = APICop::OAuth2::AccessToken::Bearer.new(:access_token => 'access_token')
    end
  end
  let(:params) do
    {
      :grant_type => 'password',
      :client_id  => 'client_id',
      :username   => 'nov',
      :password   => 'secret'
    }
  end
  subject { request.post('/', :params => params) }

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

  [:username, :password].each do |required|
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
