require 'spec_helper.rb'

describe APICop::OAuth2::Client::Grant::AuthorizationCode do
  let(:redirect_uri) { 'https://client.example.com/callback' }
  let(:grant) { APICop::OAuth2::Client::Grant::AuthorizationCode }

  context 'when code is given' do
    let :attributes do
      { :code => 'code' }
    end

    context 'when redirect_uri is given' do
      let :attributes do
        { :code => 'code', :redirect_uri => redirect_uri }
      end
      subject { grant.new attributes }
      context 'redirect_uri' do
        it { expect(subject.redirect_uri).to eq redirect_uri }
      end
      context '#as_json' do
        it { expect(subject.as_json).to eq({ :grant_type   => :authorization_code,
                                             :code         => 'code',
                                             :redirect_uri => redirect_uri }
                                        ) }
      end
    end

    context 'otherwise' do
      subject { grant.new attributes }
      context 'redirect_uri' do
        it { expect(subject.redirect_uri).to be_nil }
      end
      context '#as_json' do
        it { expect(subject.as_json).to eq({ :grant_type => :authorization_code, :code => 'code', :redirect_uri => nil }
                                        ) }
      end
    end
  end

  context 'otherwise' do
    it do
      expect { grant.new }.to raise_error AttrRequired::AttrMissing
    end
  end
end
