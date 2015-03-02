require 'spec_helper.rb'

describe APICop::OAuth2::Server::Abstract::Error do

  context 'when full attributes are given' do
    subject do
      APICop::OAuth2::Server::Abstract::Error.new 400, :invalid_request, 'Missing some required params', :uri => 'http://server.example.com/error'
    end
    context 'status' do
      it { expect(subject.status).to eq 400 }
    end
    context 'error' do
      it { expect(subject.error).to eq :invalid_request }
    end
    context 'description' do
      it { expect(subject.description).to eq 'Missing some required params' }
    end
    context 'uri' do
      it { expect(subject.uri).to eq 'http://server.example.com/error' }
    end
    context 'protocol_params' do
      it { expect(subject.protocol_params).to eq({
                                                   :error             => :invalid_request,
                                                   :error_description => 'Missing some required params',
                                                   :error_uri         => 'http://server.example.com/error'
                                                 }) }
    end
  end

  context 'when optional attributes are not given' do
    subject do
      APICop::OAuth2::Server::Abstract::Error.new 400, :invalid_request
    end
    context 'status' do
      it { expect(subject.status).to eq 400 }
    end
    context 'error' do
      it { expect(subject.error).to eq :invalid_request }
    end
    context 'description' do
      it { expect(subject.description).to be_nil }
    end
    context 'uri' do
      it { expect(subject.uri).to be_nil }
    end
    context 'protocol_params' do
      it { expect(subject.protocol_params).to eq({
                                                   :error             => :invalid_request,
                                                   :error_description => nil,
                                                   :error_uri         => nil
                                                 }) }
    end
  end

end

describe APICop::OAuth2::Server::Abstract::BadRequest do
  context 'status' do
    it { expect(subject.status).to eq 400 }
  end
end

describe APICop::OAuth2::Server::Abstract::Unauthorized do
  context 'status' do
    it { expect(subject.status).to eq 401 }
  end
end

describe APICop::OAuth2::Server::Abstract::Forbidden do
  context 'status' do
    it { expect(subject.status).to eq 403 }
  end
end

describe APICop::OAuth2::Server::Abstract::ServerError do
  context 'status' do
    it { expect(subject.status).to eq 500 }
  end
end

describe APICop::OAuth2::Server::Abstract::TemporarilyUnavailable do
  context 'status' do
    it { expect(subject.status).to eq 503 }
  end
end
