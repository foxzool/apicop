require 'spec_helper'

describe APICop::OAuth2 do
  subject { APICop::OAuth2 }
  after { APICop::OAuth2.debugging = false }

  its(:logger) { should be_a Logger }
  its(:debugging?) { should == false }

  describe '.debug!' do
    before { APICop::OAuth2.debug! }
    its(:debugging?) { should == true }
  end

  describe '.debug' do
    it 'should enable debugging within given block' do
      APICop::OAuth2.debug do
        APICop::OAuth2.debugging?.should == true
      end
      APICop::OAuth2.debugging?.should == false
    end

    it 'should not force disable debugging' do
      APICop::OAuth2.debug!
      APICop::OAuth2.debug do
        APICop::OAuth2.debugging?.should == true
      end
      APICop::OAuth2.debugging?.should == true
    end
  end

  describe '.http_config' do
    context 'when request_filter added' do
      context 'when "debug!" is called' do
        after { APICop::OAuth2.reset_http_config! }

        it 'should put Debugger::RequestFilter at last' do
          APICop::OAuth2.debug!
          APICop::OAuth2.http_config do |config|
            config.request_filter << Proc.new {}
          end
          APICop::OAuth2.http_client.request_filter.last.should be_instance_of APICop::OAuth2::Debugger::RequestFilter
        end

        it 'should reset_http_config' do
          APICop::OAuth2.debug!
          APICop::OAuth2.http_config do |config|
            config.request_filter << Proc.new {}
          end
          size = APICop::OAuth2.http_client.request_filter.size
          APICop::OAuth2.reset_http_config!
          APICop::OAuth2.http_client.request_filter.size.should == size - 1
        end

      end
    end
  end

  describe ".http_client" do
    context "when local_http_config is used" do
      it "should correctly set request_filter" do
        clnt1 = APICop::OAuth2.http_client
        clnt2 = APICop::OAuth2.http_client("my client") do |config|
          config.request_filter << Proc.new {}
        end
        clnt3 = APICop::OAuth2.http_client

        clnt1.request_filter.size.should == clnt3.request_filter.size
        clnt1.request_filter.size.should == clnt2.request_filter.size - 1

      end
    end
  end
end
