require 'spec_helper.rb'

describe APICop::OAuth2::Client::Grant::Password do
  let(:grant) { APICop::OAuth2::Client::Grant::Password }

  context 'when username is given' do
    let :attributes do
      { :username => 'username' }
    end

    context 'when password is given' do
      let :attributes do
        { :username => 'username', :password => 'password' }
      end
      subject { grant.new attributes }
      context '#as_json' do
        it { expect(subject.as_json).to eq({ :grant_type => :password, :username => 'username', :password => 'password' }) }
      end
    end

    context 'otherwise' do
      it do
        expect { grant.new attributes }.to raise_error AttrRequired::AttrMissing
      end
    end
  end

  context 'otherwise' do
    it do
      expect { grant.new }.to raise_error AttrRequired::AttrMissing
    end
  end
end
