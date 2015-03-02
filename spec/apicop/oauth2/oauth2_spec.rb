require 'spec_helper'

describe APICop::OAuth2 do
  subject { APICop::OAuth2 }
  after { APICop::OAuth2.debugging = false }

  context 'logger' do
    it { expect(subject.logger).to be_a(Logger) }
  end

  context 'debugging?' do
    it { expect(subject.debugging?).to be_falsey }
  end

  describe '.debug!' do
    before { APICop::OAuth2.debug! }
    context 'debugging?' do
      it { expect(subject.debugging?).to be_truthy }
    end
  end

  describe '.debug' do
    it 'should enable debugging within given block' do
      APICop::OAuth2.debug do
        expect(APICop::OAuth2.debugging?).to be_truthy
      end
      expect(APICop::OAuth2.debugging?).to be_falsey
    end

    it 'should not force disable debugging' do
      APICop::OAuth2.debug!
      APICop::OAuth2.debug do
        expect(APICop::OAuth2.debugging?).to be_truthy
      end
      expect(APICop::OAuth2.debugging?).to be_truthy
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
          expect(APICop::OAuth2.http_client.request_filter.last).to be_instance_of APICop::OAuth2::Debugger::RequestFilter
        end

        it 'should reset_http_config' do
          APICop::OAuth2.debug!
          APICop::OAuth2.http_config do |config|
            config.request_filter << Proc.new {}
          end
          size = APICop::OAuth2.http_client.request_filter.size
          APICop::OAuth2.reset_http_config!
          expect(APICop::OAuth2.http_client.request_filter.size).to eq(size - 1)
        end

      end
    end
  end

  describe ".http_client" do
    context "when local_http_config is used" do
      it "should correctly set request_filter" do
        client1 = APICop::OAuth2.http_client
        client2 = APICop::OAuth2.http_client("my client") do |config|
          config.request_filter << Proc.new {}
        end
        client3 = APICop::OAuth2.http_client

        expect(client1.request_filter.size).to eq(client3.request_filter.size)
        expect(client1.request_filter.size).to eq(client2.request_filter.size - 1)
      end
    end
  end
end
