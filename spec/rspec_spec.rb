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

  describe "#stub_grpc_service.to receive_rpc" do
    let(:service) { Hello::Hello }
    let(:action) { :hello }

    around do |blk|
      ProtoPharm.disable_net_connect!
      blk.call
      ProtoPharm.allow_net_connect!
    end

    context "with #and_return" do
      shared_examples_for "returns response" do
        it { expect(client.send_message("hello!")).to eq(response) }

        context "when return_op is true" do
          let(:client_call) { client.send_message("hello!", return_op: true) }
          let!(:execute) { client_call.execute }

          it "returns an executable operation" do
            expect(client_call).to be_a ProtoPharm::OperationStub
          end

          it "returns the stubbed response when executed" do
            expect(execute).to eq response
          end

          it "records the request as received" do
            expect(service).to have_received_rpc(action).with(msg: "hello!")
          end
        end
      end

      context "when passed param is hash" do
        let(:params) { { msg: "test" } }
        let(:response) { Hello::HelloResponse.new(params) }

        before { allow_grpc_service(service).to receive_rpc(action).and_return(**params) }

        it_behaves_like "returns response"
      end

      context "when passed param is proto object" do
        let(:response) { Hello::HelloResponse.new(msg: "test") }

        before { allow_grpc_service(service).to receive_rpc(action).and_return(response) }

        it_behaves_like "returns response"
      end
    end

    context "with #and_raise" do
      let(:exception) { StandardError.new("message") }

      before { allow_grpc_service(service).to receive_rpc(action).and_raise(exception) }

      it "raises the stubbed exception" do
        expect { client.send_message("hello!") }.to raise_error(exception.class, exception.message)
        expect(service).to have_received_rpc(action).with(msg: "hello!")
      end
    end

    context "with #and_fail_with" do
      let(:message) { nil }
      let(:metadata) { Hash[*Faker::Hipster.unique.words(number: 4).map(&:to_sym)] }

      before { allow_grpc_service(service).to receive_rpc(action).and_fail_with(:not_found, message, metadata: metadata) }

      it "raises the expected error" do
        expect { client.send_message("hello!") }.to raise_error do |exception|
          expect(exception).to be_a GRPC::NotFound
          expect(exception.message).to eq "5:#{message}"
          expect(exception.metadata).to eq metadata
          expect(service).to have_received_rpc(action).with(msg: "hello!")
        end
      end
    end

    context "with #and_fail" do
      before { allow_grpc_service(service).to receive_rpc(action).and_fail }

      it "raises the expected error" do
        expect { client.send_message("hello!") }.to raise_error do |exception|
          expect(exception).to be_a GRPC::InvalidArgument
          expect(exception.message).to eq "3:"
          expect(service).to have_received_rpc(action).with(msg: "hello!")
        end
      end
    end

    describe ".with" do
      context "when passed param is hash" do
        let(:request_params) { { msg: "hello!" } }
        let(:response_params) { { msg: "test" } }
        let(:response) { Hello::HelloResponse.new(response_params) }

        context "with equal request" do
          before do
            allow_grpc_service(service).to receive_rpc(action).with(**request_params).and_return(**response_params)
          end

          it { expect(client.send_message("hello!")).to eq(response) }

          context "and they are two mocking request" do
            let(:response_params2) { { msg: "test2" } }
            let(:response2) { Hello::HelloResponse.new(response_params2) }

            before do
              allow_grpc_service(service).to receive_rpc(action).with(**request_params).and_return(**response_params2)
            end

            it "returns newest result" do
              expect(client.send_message("hello!")).to eq(response2)
            end
          end
        end

        context "with not equal request" do
          let(:request_params) { { msg: "hello!" } }

          before do
            allow_grpc_service(service).to receive_rpc(action).with(**request_params).and_return(**response_params)
          end

          it { expect { client.send_message("hello2!") }.to raise_error(ProtoPharm::NetConnectNotAllowedError) }
        end
      end

      context "when passed param is proto object" do
        let(:request) { Hello::HelloRequest.new(msg: "hello!") }
        let(:response) { Hello::HelloResponse.new(msg: "test") }

        context "with equal request" do
          before do
            allow_grpc_service(service).to receive_rpc(action).with(request).and_return(response)
          end

          it { expect(client.send_message("hello!")).to eq(response) }

          context "and they are two mocking request" do
            let(:response2) { Hello::HelloResponse.new(msg: "test2") }

            before do
              allow_grpc_service(service).to receive_rpc(action).with(request).and_return(response2)
            end

            it "returns newest result" do
              expect(client.send_message("hello!")).to eq(response2)
            end
          end
        end

        context "with not equal request" do
          let(:request) { Hello::HelloRequest.new(msg: "hello!") }

          before do
            allow_grpc_service(service).to receive_rpc(action).with(request).and_return(response)
          end

          it { expect { client.send_message("hello2!") }.to raise_error(ProtoPharm::NetConnectNotAllowedError) }
        end
      end
    end
  end
end
