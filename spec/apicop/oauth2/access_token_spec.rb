require 'spec_helper'

describe APICop::OAuth2::AccessToken do
  let :token do
    APICop::OAuth2::AccessToken::Bearer.new(
      :access_token => 'access_token',
      :refresh_token => 'refresh_token',
      :expires_in => 3600,
      :scope => [:scope1, :scope2]
    )
  end
  subject { token }

  context '#access_token' do
    it { expect(subject.access_token).to eq 'access_token' }
  end
  context '#refresh_token' do
    it { expect(subject.refresh_token).to eq 'refresh_token' }
  end
  context '#expires_in' do
    it { expect(subject.expires_in).to eq 3600 }
  end
  context '#scope' do
    it { expect(subject.scope).to eq [:scope1, :scope2] }
  end
  context '#token_response' do
    it { expect(subject.token_response).to eq({ :token_type => :bearer,
                                                :access_token => 'access_token',
                                                :refresh_token => 'refresh_token',
                                                :expires_in => 3600,
                                                :scope => 'scope1 scope2'
                                              }) }
  end

  context 'when access_token is missing' do
    it do
      expect do
        APICop::OAuth2::AccessToken::Bearer.new(
          :refresh_token => 'refresh_token',
          :expires_in => 3600,
          :scope => [:scope1, :scope2]
        )
      end.to raise_error AttrRequired::AttrMissing
    end
  end

  context 'otherwise' do
    it do
      expect do
        APICop::OAuth2::AccessToken::Bearer.new(
          :access_token => 'access_token'
        )
      end.not_to raise_error
    end
  end

  let(:resource_endpoint) { 'https://server.example.com/resources/fake' }
  [:get, :delete, :post, :put].each do |method|
    describe method do
      it 'should delegate to HTTPClient with Authenticator filter' do
        expect(token.httpclient).to receive(method).with(resource_endpoint)
        expect(token.httpclient.request_filter.last).to be_a APICop::OAuth2::AccessToken::Authenticator
        token.send method, resource_endpoint
      end
    end

    context 'in debug mode' do
      it do
        APICop::OAuth2.debug do
          token.httpclient.request_filter[-2].should be_a APICop::OAuth2::AccessToken::Authenticator
          expect(token.httpclient.request_filter[-2]).to be_a APICop::OAuth2::AccessToken::Authenticator
        end
      end
    end
  end
end
