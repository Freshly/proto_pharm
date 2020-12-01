# frozen_string_literal: true

RSpec.describe ProtoPharm::RSpec do
  require "proto_pharm/rspec"

  let(:client) { HelloClient.new }

  before { ProtoPharm.enable! }

  context "with network connections enabled" do
    before { ProtoPharm.allow_net_connect! }

    context "when request_response" do
      it { expect { client.send_message("hello!") }.to raise_error(GRPC::Unavailable) }
    end

    context "when server_stream" do
      it { expect { client.send_message("hello!", server_stream: true) }.to raise_error(GRPC::Unavailable) }
    end

    context "when client_stream" do
      it { expect { client.send_message("hello!", client_stream: true) }.to raise_error(GRPC::Unavailable) }
    end

    context "when bidi_stream" do
      it { expect { client.send_message("hello!", client_stream: true, server_stream: true) }.to raise_error(GRPC::Unavailable) }
    end
  end

  context ".disable_net_connect!" do
    before { ProtoPharm.disable_net_connect! }

    context "when request_response" do
      it { expect { client.send_message("hello!") }.to raise_error(ProtoPharm::NetConnectNotAllowedError) }
    end

    context "when server_stream" do
      it { expect { client.send_message("hello!", server_stream: true) }.to raise_error(ProtoPharm::NetConnectNotAllowedError) }
    end

    context "when client_stream" do
      it { expect { client.send_message("hello!", client_stream: true) }.to raise_error(ProtoPharm::NetConnectNotAllowedError) }
    end

    context "when bidi_stream" do
      it { expect { client.send_message("hello!", client_stream: true, server_stream: true) }.to raise_error(ProtoPharm::NetConnectNotAllowedError) }
    end

    # should be in disable_net_connect! context
    context "allow_net_connect!" do
      before do
        ProtoPharm.allow_net_connect!
      end

      context "when request_response" do
        it { expect { client.send_message("hello!") }.to raise_error(GRPC::Unavailable) }
      end

      context "when server_stream" do
        it { expect { client.send_message("hello!", server_stream: true) }.to raise_error(GRPC::Unavailable) }
      end

      context "when client_stream" do
        it { expect { client.send_message("hello!", client_stream: true) }.to raise_error(GRPC::Unavailable) }
      end

      context "when bidi_stream" do
        it { expect { client.send_message("hello!", client_stream: true, server_stream: true) }.to raise_error(GRPC::Unavailable) }
      end

      context "change disable -> allow -> disable " do
        before do
          ProtoPharm.disable_net_connect!
        end

        context "when request_response" do
          it { expect { client.send_message("hello!") }.to raise_error(ProtoPharm::NetConnectNotAllowedError) }
        end

        context "when server_stream" do
          it { expect { client.send_message("hello!", server_stream: true) }.to raise_error(ProtoPharm::NetConnectNotAllowedError) }
        end

        context "when client_stream" do
          it { expect { client.send_message("hello!", client_stream: true) }.to raise_error(ProtoPharm::NetConnectNotAllowedError) }
        end

        context "when bidi_stream" do
          it { expect { client.send_message("hello!", client_stream: true, server_stream: true) }.to raise_error(ProtoPharm::NetConnectNotAllowedError) }
        end
      end
    end
  end
end
