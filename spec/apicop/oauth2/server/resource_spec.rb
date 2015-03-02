require 'spec_helper.rb'

describe APICop::OAuth2::Server::Resource do
  subject { APICop::OAuth2::Server::Resource.new(simple_app, 'realm') }
  context 'realm' do
    it { expect(subject.realm).to eq 'realm' }
  end
end

describe APICop::OAuth2::Server::Resource::Request do
  let(:env) { Rack::MockRequest.env_for('/protected_resource') }
  let(:request) { APICop::OAuth2::Server::Resource::Request.new(env) }

  describe '#setup!' do
    it do
      expect { request.setup! }.to raise_error(RuntimeError, 'Define me!')
    end
  end

  describe '#oauth2?' do
    it do
      expect { request.oauth2? }.to raise_error(RuntimeError, 'Define me!')
    end
  end
end
