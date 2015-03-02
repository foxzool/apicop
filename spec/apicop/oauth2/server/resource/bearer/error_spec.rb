require 'spec_helper.rb'

describe APICop::OAuth2::Server::Resource::Bearer::Unauthorized do
  let(:error) { APICop::OAuth2::Server::Resource::Bearer::Unauthorized.new(:invalid_token) }

  it { is_expected.to be_a APICop::OAuth2::Server::Resource::Unauthorized }

  describe '#scheme' do
    subject { error }
    its(:scheme) { should == :Bearer }
  end

  describe '#finish' do
    it 'should use Bearer scheme' do
      status, header, response = error.finish
      expect(header['WWW-Authenticate']).to include 'Bearer'
    end
  end
end

describe APICop::OAuth2::Server::Resource::Bearer::ErrorMethods do
  let(:unauthorized) { APICop::OAuth2::Server::Resource::Bearer::Unauthorized }
  let(:redirect_uri) { 'http://client.example.com/callback' }
  let(:default_description) { APICop::OAuth2::Server::Resource::ErrorMethods::DEFAULT_DESCRIPTION }
  let(:env) { Rack::MockRequest.env_for("/authorize?client_id=client_id") }
  let(:request) { APICop::OAuth2::Server::Resource::Bearer::Request.new env }

  describe 'unauthorized!' do
    it do
      expect { request.unauthorized! :invalid_client }.to raise_error unauthorized
    end
  end

  APICop::OAuth2::Server::Resource::Bearer::ErrorMethods::DEFAULT_DESCRIPTION.keys.each do |error_code|
    method = "#{error_code}!"
    case error_code
    when :invalid_request
      # ignore
    when :insufficient_scope
      # ignore
    else
      describe method do
        it "should raise APICop::OAuth2::Server::Resource::Bearer::Unauthorized with error = :#{error_code}" do
          expect { request.send method }.to raise_error(unauthorized) { |error|
                                              expect(error.error).to eq error_code
                                              expect(error.description).to eq default_description[error_code]
                                            }
        end
      end
    end
  end
end
