require 'spec_helper.rb'

describe APICop::OAuth2::Client::Grant::RefreshToken do
  let(:grant) { APICop::OAuth2::Client::Grant::RefreshToken }

  context 'when refresh_token is given' do
    let :attributes do
      { :refresh_token => 'refresh_token' }
    end
    subject { grant.new attributes }
    context '#as_json' do
      it { expect(subject.as_json).to eq({ :grant_type => :refresh_token, :refresh_token => 'refresh_token' }) }
    end
  end

  context 'otherwise' do
    it do
      expect { grant.new }.to raise_error AttrRequired::AttrMissing
    end
  end
end
