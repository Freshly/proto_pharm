# frozen_string_literal: true

RSpec.describe ProtoPharm do
  let(:client) { HelloClient.new }

  around do |blk|
    described_class.enable!
    blk.call
    described_class.disable!
    described_class.reset!
  end

  shared_context "with disabled network connections" do
    around do |blk|
      described_class.disable_net_connect!
      blk.call
      described_class.allow_net_connect!
    end
  end

  describe ".enable!" do
    include_context "with disabled network connections"

    it { expect { client.send_message("hello!") }.to raise_error(described_class::NetConnectNotAllowedError) }

    context "when described_class is disabled" do
      before do
        described_class.disable!
      end

      it { expect { client.send_message("hello!") }.to raise_error(GRPC::Unavailable) }

      context "when described_class is re-enabled" do
        before do
          described_class.enable!
        end

        it { expect { client.send_message("hello!") }.to raise_error(described_class::NetConnectNotAllowedError) }
      end
    end
  end

  describe ".stub_grpc_action" do
    let(:service) { Hello::Hello }
    let(:action) { :Hello }

    context "with #to_return" do
      shared_examples_for "returns response" do
        it { expect(client.send_message("hello!")).to eq(response) }

        context "when return_op is true" do
          let!(:client_call) { client.send_message("hello!", return_op: true) }
          let(:execute) { client_call.execute }

          it "returns an executable operation" do
            expect(client_call).to be_a described_class::OperationStub
          end

          it "returns the stubbed response when executed" do
            expect(execute).to eq response
          end

          it "records the request as received" do
            expect(service).not_to have_received_rpc(action)
            execute
            expect(service).to have_received_rpc(action)
            expect(service).to have_received_rpc(action).with(msg: "hello!")
          end
        end
      end

      context "when passed param is hash" do
        let(:params) { { msg: "test" } }
        let(:response) { Hello::HelloResponse.new(params) }

        before do
          described_class.enable!
          described_class.stub_grpc_action(service, action).to_return(**params)
        end

        it_behaves_like "returns response"
      end

      context "when passed param is proto object" do
        let(:response) { Hello::HelloResponse.new(msg: "test") }

        before do
          described_class.enable!
          described_class.stub_grpc_action(service, action).to_return(response)
        end

        it_behaves_like "returns response"
      end
    end

    context "with #to_raise" do
      let(:exception) { StandardError.new("message") }

      before do
        described_class.enable!
        described_class.stub_grpc_action(service, action).to_raise(exception)
      end

      it "raises the stubbed exception" do
        expect { client.send_message("hello!") }.to raise_error(exception.class, exception.message)
        expect(service).to have_received_rpc(action).with(msg: "hello!")
      end
    end

    context "with #to_fail_with" do
      let(:message) { nil }
      let(:metadata) { Hash[*Faker::Hipster.unique.words(number: 4).map(&:to_sym)] }

      before do
        described_class.enable!
        described_class.stub_grpc_action(service, action).to_fail_with(:not_found, message, metadata: metadata)
      end

      it "raises the expected error" do
        expect { client.send_message("hello!") }.to raise_error do |exception|
          expect(exception).to be_a GRPC::NotFound
          expect(exception.message).to eq "5:#{message}"
          expect(exception.metadata).to eq metadata
          expect(service).to have_received_rpc(action).with(msg: "hello!")
        end
      end
    end

    context "with #to_fail" do
      before do
        described_class.enable!
        described_class.stub_grpc_action(service, action).to_fail
      end

      it "raises the expected error" do
        expect { client.send_message("hello!") }.to raise_error do |exception|
          expect(exception).to be_a GRPC::InvalidArgument
          expect(exception.message).to eq "3:"
          expect(service).to have_received_rpc(action).with(msg: "hello!")
        end
      end
    end

    describe ".with" do
      include_context "with disabled network connections"

      context "when passed param is hash" do
        let(:request_params) { { msg: "hello!" } }
        let(:response_params) { { msg: "test" } }
        let(:response) { Hello::HelloResponse.new(response_params) }

        context "with equal request" do
          before do
            described_class.stub_grpc_action(service, action).with(**request_params).to_return(**response_params)
          end

          it { expect(client.send_message("hello!")).to eq(response) }

          context "and they are two mocking request" do
            let(:response_params2) { { msg: "test2" } }
            let(:response2) { Hello::HelloResponse.new(response_params2) }

            before do
              described_class.stub_grpc_action(service, action).with(**request_params).to_return(**response_params2)
            end

            it "returns newest result" do
              expect(client.send_message("hello!")).to eq(response2)
            end
          end
        end

        context "with not equal request" do
          let(:request_params) { { msg: "hello!" } }

          before do
            described_class.stub_grpc_action(service, action).with(**request_params).to_return(**response_params)
          end

          it { expect { client.send_message("hello2!") }.to raise_error(described_class::NetConnectNotAllowedError) }
        end
      end

      context "when passed param is proto object" do
        let(:request) { Hello::HelloRequest.new(msg: "hello!") }
        let(:response) { Hello::HelloResponse.new(msg: "test") }

        context "with equal request" do
          before do
            described_class.stub_grpc_action(service, action).with(request).to_return(response)
          end

          it { expect(client.send_message("hello!")).to eq(response) }

          context "and they are two mocking request" do
            let(:response2) { Hello::HelloResponse.new(msg: "test2") }

            before do
              described_class.stub_grpc_action(service, action).with(request).to_return(response2)
            end

            it "returns newest result" do
              expect(client.send_message("hello!")).to eq(response2)
            end
          end
        end

        context "with not equal request" do
          let(:request) { Hello::HelloRequest.new(msg: "hello!") }

          before do
            described_class.stub_grpc_action(service, action).with(request).to_return(response)
          end

          it { expect { client.send_message("hello2!") }.to raise_error(described_class::NetConnectNotAllowedError) }
        end
      end
    end
  end

  describe ".stub_request" do
    include_context "with disabled network connections"

    context "with to_return" do
      let(:response) { Hello::HelloResponse.new(msg: "test") }

      before do
        described_class.enable!
        described_class.stub_request("/hello.hello/Hello").to_return(response)
      end

      it { expect(client.send_message("hello!")).to eq(response) }

      context "when return_op is true" do
        let(:client_call) { client.send_message("hello!", return_op: true) }

        it "returns an executable operation" do
          expect(client_call).to be_a described_class::OperationStub
          expect(client_call.execute).to eq response
        end
      end
    end

    context "with to_raise" do
      let(:exception) { StandardError.new("message") }

      before do
        described_class.enable!
        described_class.stub_request("/hello.hello/Hello").to_raise(exception)
      end

      it { expect { client.send_message("hello!") }.to raise_error(exception.class) }
    end

    describe ".with" do
      let(:response) do
        Hello::HelloResponse.new(msg: "test")
      end

      context "with equal request" do
        before do
          described_class.stub_request("/hello.hello/Hello").with(Hello::HelloRequest.new(msg: "hello2!")).to_return(response)
        end

        it { expect(client.send_message("hello2!")).to eq(response) }

        context "and they are two mocking request" do
          let(:response2) do
            Hello::HelloResponse.new(msg: "test")
          end

          before do
            described_class.stub_request("/hello.hello/Hello").with(Hello::HelloRequest.new(msg: "hello2!")).to_return(response2)
          end

          it "returns newest result" do
            expect(client.send_message("hello2!")).to eq(response2)
          end
        end
      end

      context "with not equal request" do
        before do
          described_class.stub_request("/hello.hello/Hello").with(Hello::HelloRequest.new(msg: "hello!")).to_return(response)
        end

        it { expect { client.send_message("hello2!") }.to raise_error(described_class::NetConnectNotAllowedError) }
      end
    end
  end

  describe "#request_including" do
    let(:response) do
      Hello::HelloResponse.new(msg: "test")
    end

    context "with equal request" do
      before do
        described_class.stub_request("/hello.hello/Hello").with(described_class.request_including(msg: "hello2!")).to_return(response)
      end

      it { expect(client.send_message("hello2!")).to eq(response) }
    end

    context "with more complex example" do
      let(:client) do
        Request::Request::Stub.new("localhost:8000", :this_channel_is_insecure)
      end

      let(:response) do
        Request::HelloResponse.new(msg: "test")
      end

      let(:request) do
        Request::HelloRequest.new(
          msg: "hello2!",
          n: 10,
          ptype: Request::PhoneType::MOBILE,
          inner: Request::InnerRequest.new(
            msg: "hello!",
            n: 11,
            ptype: Request::PhoneType::WORK,
          ),
        )
      end

      it "returns mock object" do
        described_class.stub_request("/request.request/Hello").with(described_class.request_including(msg: "hello2!")).to_return(response)
        expect(client.hello(request)).to eq(response)
      end

      it "returns mock object" do
        h = { msg: "hello2!", ptype: Request::PhoneType.lookup(Request::PhoneType::MOBILE), inner: { msg: "hello!" } }
        described_class.stub_request("/request.request/Hello").with(described_class.request_including(h)).to_return(response)
        expect(client.hello(request)).to eq(response)
      end
    end

    context "with not equal request" do
      before do
        described_class.stub_request("/hello.hello/Hello").with(described_class.request_including(msg: "hello!")).to_return(response)
      end

      it { expect { client.send_message("hello2!") }.to raise_error(GRPC::Unavailable) }
    end
  end
end
