require 'spec_helper.rb'

describe APICop::OAuth2::Server::Authorize::Token do
  let(:request) { Rack::MockRequest.new app }
  let(:redirect_uri) { 'http://client.example.com/callback' }
  let(:access_token) { 'access_token' }
  let(:response) { request.get("/?response_type=token&client_id=client&redirect_uri=#{redirect_uri}&state=state") }

  context "when approved" do
    subject { response }
    let(:bearer_token) { APICop::OAuth2::AccessToken::Bearer.new(:access_token => access_token) }
    let :app do
      APICop::OAuth2::Server::Authorize.new do |request, response|
        response.redirect_uri = redirect_uri
        response.access_token = bearer_token
        response.approve!
      end
    end
    context 'status' do
      it { expect(subject.status).to eq 302 }
    end
    context 'location' do
      it { expect(subject.location).to eq "#{redirect_uri}#access_token=#{access_token}&state=state&token_type=bearer" }
    end

    context 'when refresh_token is given' do
      let :bearer_token do
        APICop::OAuth2::AccessToken::Bearer.new(
          :access_token => access_token,
          :refresh_token => 'refresh'
        )
      end
      context 'location' do
        it { expect(subject.location).to eq "#{redirect_uri}#access_token=#{access_token}&state=state&token_type=bearer" }
      end
    end

    context 'when redirect_uri is missing' do
      let :app do
        APICop::OAuth2::Server::Authorize.new do |request, response|
          response.access_token = bearer_token
          response.approve!
        end
      end
      it do
        expect { response }.to raise_error AttrRequired::AttrMissing
      end
    end

    context 'when access_token is missing' do
      let :app do
        APICop::OAuth2::Server::Authorize.new do |request, response|
          response.redirect_uri = redirect_uri
          response.approve!
        end
      end
      it do
        expect { response }.to raise_error AttrRequired::AttrMissing
      end
    end
  end

  context 'when denied' do
    let :app do
      APICop::OAuth2::Server::Authorize.new do |request, response|
        request.verify_redirect_uri! redirect_uri
        request.access_denied!
      end
    end
    it 'should redirect with error in fragment' do
      expect(response.status).to eq 302
      error_message = {
        :error => :access_denied,
        :error_description => APICop::OAuth2::Server::Authorize::ErrorMethods::DEFAULT_DESCRIPTION[:access_denied]
      }
      expect(response.location).to eq "#{redirect_uri}##{error_message.to_query}&state=state"
    end
  end
end
