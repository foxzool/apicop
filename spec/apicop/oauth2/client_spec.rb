require 'spec_helper.rb'

describe APICop::OAuth2::Client do
  let :client do
    APICop::OAuth2::Client.new(
      :identifier => 'client_id',
      :secret => 'client_secret',
      :host => 'server.example.com',
      :redirect_uri => 'https://client.example.com/callback'
    )
  end
  subject { client }

  context '#indentifier' do
    it { expect(subject.identifier).to eq 'client_id' }
  end
  context '#secret' do
    it { expect(subject.secret).to eq 'client_secret' }
  end
  context '#authorization_endpoint' do
    it { expect(subject.authorization_endpoint).to eq '/oauth2/authorize' }
  end
  context '#token_endpoint' do
    it { expect(subject.token_endpoint).to eq '/oauth2/token' }
  end

  context 'when identifier is missing' do
    it do
      expect { APICop::OAuth2::Client.new }.to raise_error AttrRequired::AttrMissing
    end
  end

  describe '#authorization_uri' do
    subject { client.authorization_uri }
    it { is_expected.to include 'https://server.example.com/oauth2/authorize' }
    it { is_expected.to include 'client_id=client_id' }
    it { is_expected.to include 'redirect_uri=https%3A%2F%2Fclient.example.com%2Fcallback' }
    it { is_expected.to include 'response_type=code' }

    context 'when endpoints are absolute URIs' do
      before do
        client.authorization_endpoint = 'https://server2.example.com/oauth/authorize'
        client.token_endpoint = 'https://server2.example.com/oauth/token'
      end
      it { is_expected.to include 'https://server2.example.com/oauth/authorize' }
    end

    context 'when endpoints are relative URIs' do
      before do
        client.authorization_endpoint = '/oauth/authorize'
        client.token_endpoint = '/oauth/token'
      end
      it { is_expected.to include 'https://server.example.com/oauth/authorize' }
    end

    context 'when scheme is specified' do
      before { client.scheme = 'http' }
      it { is_expected.to include 'http://server.example.com/oauth2/authorize' }
    end

    context 'when response_type is token' do
      subject { client.authorization_uri(:response_type => :token) }
      it { is_expected.to include 'response_type=token' }
    end

    context 'when response_type is an Array' do
      subject { client.authorization_uri(:response_type => [:token, :code]) }
      it { is_expected.to include 'response_type=token+code' }
    end

    context 'when scope is given' do
      subject { client.authorization_uri(:scope => [:scope1, :scope2]) }
      it { is_expected.to include 'scope=scope1+scope2' }
    end
  end

  describe '#authorization_code=' do
    before { client.authorization_code = 'code' }
    subject { client.instance_variable_get('@grant') }
    it { is_expected.to be_instance_of APICop::OAuth2::Client::Grant::AuthorizationCode }
  end

  describe '#resource_owner_credentials=' do
    before { client.resource_owner_credentials = 'username', 'password' }
    subject { client.instance_variable_get('@grant') }
    it { is_expected.to be_instance_of APICop::OAuth2::Client::Grant::Password }
  end

  describe '#refresh_token=' do
    before { client.refresh_token = 'refresh_token' }
    subject { client.instance_variable_get('@grant') }
    it { is_expected.to be_instance_of APICop::OAuth2::Client::Grant::RefreshToken }
  end

  describe '#access_token!' do
    subject { client.access_token! }

    describe 'client authentication method' do
      before do
        client.authorization_code = 'code'
      end

      it 'should be Basic auth as default' do
        mock_response(
          :post,
          'https://server.example.com/oauth2/token',
          'tokens/bearer.json',
          :request_header => {
            'Authorization' => 'Basic Y2xpZW50X2lkOmNsaWVudF9zZWNyZXQ='
          }
        )
        client.access_token!
      end

      context 'when other auth method specified' do
        it do
          mock_response(
            :post,
            'https://server.example.com/oauth2/token',
            'tokens/bearer.json',
            :params => {
              :client_id => 'client_id',
              :client_secret => 'client_secret',
              :code => 'code',
              :grant_type => 'authorization_code',
              :redirect_uri => 'https://client.example.com/callback'
            }
          )
          client.access_token! :client_auth_body
        end
      end
    end

    describe 'scopes' do
      context 'when scope option given' do
        it 'should specify given scope' do
          mock_response(
            :post,
            'https://server.example.com/oauth2/token',
            'tokens/bearer.json',
            :params => {
              :grant_type => 'client_credentials',
              :scope => 'a b'
            }
          )
          client.access_token! :scope => [:a, :b]
        end
      end
    end

    context 'when bearer token is given' do
      before do
        client.authorization_code = 'code'
        mock_response(
          :post,
          'https://server.example.com/oauth2/token',
          'tokens/bearer.json'
        )
      end
      it { is_expected.to be_instance_of APICop::OAuth2::AccessToken::Bearer }
      context "#token_type" do
        it { expect(subject.token_type).to eq :bearer }
      end
      context "#access_token" do
        it { expect(subject.access_token).to eq 'access_token' }
      end
      context "#refresh_token" do
        it { expect(subject.refresh_token).to eq 'refresh_token' }
      end
      context "#expires_in" do
        it { expect(subject.expires_in).to eq 3600 }
      end

      context 'when token type is "Bearer", not "bearer"' do
        before do
          client.authorization_code = 'code'
          mock_response(
            :post,
            'https://server.example.com/oauth2/token',
            'tokens/_Bearer.json'
          )
        end
        it { is_expected.to be_instance_of APICop::OAuth2::AccessToken::Bearer }
        context "#token_type" do
          it { expect(subject.token_type).to eq :bearer }
        end
      end
    end

    context 'when mac token is given' do
      before do
        client.authorization_code = 'code'
        mock_response(
          :post,
          'https://server.example.com/oauth2/token',
          'tokens/mac.json'
        )
      end
      it { is_expected.to be_instance_of APICop::OAuth2::AccessToken::MAC }
      context '#token_type' do
        it { expect(subject.token_type).to eq :mac }
      end
      context '#access_token' do
        it { expect(subject.access_token).to eq 'access_token' }
      end
      context '#refresh_token' do
        it { expect(subject.refresh_token).to eq 'refresh_token' }
      end
      context "#expires_in" do
        it { expect(subject.expires_in).to eq 3600 }
      end
    end

    context 'when no-type token is given (JSON)' do
      before do
        client.authorization_code = 'code'
        mock_response(
          :post,
          'https://server.example.com/oauth2/token',
          'tokens/legacy.json'
        )
      end
      it { is_expected.to be_instance_of APICop::OAuth2::AccessToken::Legacy }
      context '#token_type' do
        it { expect(subject.token_type).to eq :legacy }
      end
      context '#access_token' do
        it { expect(subject.access_token).to eq 'access_token' }
      end
      context '#refresh_token' do
        it { expect(subject.refresh_token).to eq 'refresh_token' }
      end
      context "#expires_in" do
        it { expect(subject.expires_in).to eq 3600 }
      end
    end

    context 'when no-type token is given (key-value)' do
      before do
        mock_response(
          :post,
          'https://server.example.com/oauth2/token',
          'tokens/legacy.txt'
        )
      end
      it { is_expected.to be_instance_of APICop::OAuth2::AccessToken::Legacy }
      context '#token_type' do
        it { expect(subject.token_type).to eq :legacy }
      end
      context '#access_token' do
        it { expect(subject.access_token).to eq 'access_token' }
      end
      context "#expires_in" do
        it { expect(subject.expires_in).to eq 3600 }
      end

      context 'when expires_in is not given' do
        before do
          mock_response(
            :post,
            'https://server.example.com/oauth2/token',
            'tokens/legacy_without_expires_in.txt'
          )
        end
        context "#expires_in" do
          it { expect(subject.expires_in).to be_nil }
        end
      end
    end

    context 'when unknown-type token is given' do
      before do
        client.authorization_code = 'code'
        mock_response(
          :post,
          'https://server.example.com/oauth2/token',
          'tokens/unknown.json'
        )
      end
      it do
        expect { client.access_token! }.to raise_error(StandardError, 'Unknown Token Type')
      end
    end

    context 'when error response is given' do
      before do
        mock_response(
          :post,
          'https://server.example.com/oauth2/token',
          'errors/invalid_request.json',
          :status => 400
        )
      end
      it do
        expect { client.access_token! }.to raise_error APICop::OAuth2::Client::Error
      end
    end

    context 'when no body given' do
      context 'when error given' do
        before do
          mock_response(
            :post,
            'https://server.example.com/oauth2/token',
            'blank',
            :status => 400
          )
        end
        it do
          expect { client.access_token! }.to raise_error APICop::OAuth2::Client::Error
        end
      end
    end
  end

  context 'when no host info' do
    let :client do
      APICop::OAuth2::Client.new(
        :identifier => 'client_id',
        :secret => 'client_secret',
        :redirect_uri => 'https://client.example.com/callback'
      )
    end

    describe '#authorization_uri' do
      it do
        expect { client.authorization_uri }.to raise_error 'No Host Info'
      end
    end

    describe '#access_token!' do
      it do
        expect { client.access_token! }.to raise_error 'No Host Info'
      end
    end
  end
end
