require 'spec_helper.rb'
require 'apicop/oauth2/server/authorize/extension/code_and_token'

describe APICop::OAuth2::Server::Authorize::Extension::CodeAndToken do
  let(:request) { Rack::MockRequest.new app }
  let(:redirect_uri) { 'http://client.example.com/callback' }
  let(:access_token) { 'access_token' }
  let(:authorization_code) { 'authorization_code' }
  let(:response) do
    request.get("/?response_type=code%20token&client_id=client&redirect_uri=#{redirect_uri}")
  end

  context "when approved" do
    subject { response }
    let(:bearer_token) { APICop::OAuth2::AccessToken::Bearer.new(:access_token => access_token) }
    let :app do
      APICop::OAuth2::Server::Authorize.new do |request, response|
        response.redirect_uri = redirect_uri
        response.access_token = bearer_token
        response.code = authorization_code
        response.approve!
      end
    end
    context 'status' do
      it { expect(subject.status).to eq 302 }
    end

    context 'location' do
      it { expect(subject.location).to include "#{redirect_uri}#" }
      it { expect(subject.location).to include "code=#{authorization_code}" }
      it { expect(subject.location).to include "access_token=#{access_token}" }
      it { expect(subject.location).to include 'token_type=bearer' }
    end

    context 'when refresh_token is given' do
      let :bearer_token do
        APICop::OAuth2::AccessToken::Bearer.new(
          :access_token => access_token,
          :refresh_token => 'refresh'
        )
      end
      context 'location' do
        it { expect(subject.location).to include "#{redirect_uri}#" }
        it { expect(subject.location).to include "code=#{authorization_code}" }
        it { expect(subject.location).to include "access_token=#{access_token}" }
        it { expect(subject.location).to include 'token_type=bearer' }
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
      expect(response.location).to eq "#{redirect_uri}##{error_message.to_query}"
    end
  end
end
