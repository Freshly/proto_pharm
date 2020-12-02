# frozen_string_literal: true

RSpec.describe ProtoPharm::ActionStub do
  subject(:action_stub) { described_class.new(service, endpoint) }

  let(:service) { Hello::Hello::Service }
  let(:service_name) { service.service_name }
  let(:endpoint) { :hello }

  let(:input_class) { Hello::HelloRequest }
  let(:output_class) { Hello::HelloResponse }

  describe "#response" do
    let(:exception) { StandardError.new }
    let(:value1) { { msg: "response 1" } }
    let(:value2) { { msg: "response 2" } }

    it "returns response" do
      action_stub.to_return(value1)
      expect(action_stub.response.evaluate).to eq(output_class.new(value1))
    end

    it "raises exception" do
      action_stub.to_raise(exception)
      expect { action_stub.response.evaluate }.to raise_error(StandardError)
    end

    it "returns responses in a sequence passed as array with multiple to_return calling" do
      action_stub.to_return(value1)
      action_stub.to_return(value2)
      expect(action_stub.response.evaluate).to eq(output_class.new(value1))
      expect(action_stub.response.evaluate).to eq(output_class.new(value2))
    end

    it "repeats returning last response" do
      action_stub.to_return(value1)
      action_stub.to_return(value2)
      expect(action_stub.response.evaluate).to eq(output_class.new(value1))
      expect(action_stub.response.evaluate).to eq(output_class.new(value2))
      expect(action_stub.response.evaluate).to eq(output_class.new(value2))
      expect(action_stub.response.evaluate).to eq(output_class.new(value2))
    end

    context "when not calling #to_return" do
      it "raises an error" do
        expect { action_stub.response }.to raise_error(ProtoPharm::NoResponseError)
      end
    end
  end

  describe "#with" do
    before { allow(input_class).to receive(:new).and_call_original }

    context "with a hash" do
      let(:request) { { msg: "request" } }

      it "registers request", aggregate: true do
        expect(action_stub.with(request)).to eq(action_stub)
        expect(input_class).to have_received(:new).with(request)
      end
    end

    context "with kwargs" do
      let(:request) { { msg: "Hello?" } }

      it "registers request", aggregate: true do
        expect(action_stub.with(**request)).to eq(action_stub)
        expect(input_class).to have_received(:new).with(request)
      end
    end

    context "with a proto object" do
      let(:request) { input_class.new(msg: "hello?") }

      it "registers request", aggregate: true do
        expect(action_stub.with(request)).to eq(action_stub)
      end

      context "with wrong proto class" do
        let(:request) { output_class.new(msg: "hello?") }

        it "raises InvalidProtoType" do
          expect { expect(action_stub.with(request)) }.to raise_error ProtoPharm::InvalidProtoType
        end
      end
    end
  end

  describe "#to_return" do
    before { allow(ProtoPharm::ResponsesSequence).to receive(:new).and_call_original }

    context "with a hash" do
      let(:response) { { msg: "Hello!" } }

      it "registers response", aggregate: true do
        expect(output_class).to receive(:new).with(response)

        expect(action_stub.to_return(response)).to eq(action_stub)

        expect(ProtoPharm::ResponsesSequence).to have_received(:new).with([ProtoPharm::Response::Value]).once
      end
    end

    context "with kwargs" do
      let(:response) { { msg: "Hello!" } }
      it "registers response", aggregate: true do
        expect(output_class).to receive(:new).with(**response)

        expect(action_stub.to_return(**response)).to eq(action_stub)

        expect(ProtoPharm::ResponsesSequence).to have_received(:new).with([ProtoPharm::Response::Value]).once
      end
    end

    context "with a proto object" do
      let(:response) { output_class.new(msg: "Hello!") }

      it "registers response", aggregate: true do
        expect(output_class).not_to receive(:new).with(response)

        expect(action_stub.to_return(response)).to eq(action_stub)

        expect(ProtoPharm::ResponsesSequence).to have_received(:new).with([ProtoPharm::Response::Value]).once
      end

      context "with wrong proto class" do
        let(:response) { input_class.new(msg: "hello?") }

        it "raises InvalidProtoType" do
          expect { expect(action_stub.to_return(response)) }.to raise_error ProtoPharm::InvalidProtoType
        end
      end
    end
  end

  describe "#to_raise" do
    context "with string" do
      let(:exception) { "string" }
      it "registers exception" do
        expect(ProtoPharm::ResponsesSequence).to receive(:new).with([ProtoPharm::Response::ExceptionValue]).once
        expect(action_stub.to_raise(exception)).to eq(action_stub)
      end
    end

    context "with class" do
      let(:response) { StandardError }
      it "registers exception" do
        expect(ProtoPharm::ResponsesSequence).to receive(:new).with([ProtoPharm::Response::ExceptionValue]).once
        expect(action_stub.to_raise(response)).to eq(action_stub)
      end
    end

    context "with exception instance" do
      let(:response) { StandardError.new("message") }
      it "registers exception" do
        expect(ProtoPharm::ResponsesSequence).to receive(:new).with([ProtoPharm::Response::ExceptionValue]).once
        expect(action_stub.to_raise(response)).to eq(action_stub)
      end
    end

    context "with invalid value (integer)" do
      let(:response) { 1 }
      it "raises ArgumentError" do
        expect { action_stub.to_raise(response) }.to raise_error(ArgumentError)
      end
    end

    context "with multi exceptions" do
      let(:exception) { StandardError.new("message") }
      it "registers exceptions" do
        expect(ProtoPharm::ResponsesSequence).to receive(:new).with([ProtoPharm::Response::ExceptionValue, ProtoPharm::Response::ExceptionValue]).once
        expect(action_stub.to_raise(exception, exception)).to eq(action_stub)
      end
    end
  end

  describe "#to_fail" do
    subject(:failure) { action_stub.to_fail }

    let(:expected_error) { GRPC::InvalidArgument.new }
    let(:exception) { failure.response_sequence.first.responses.first.exception }

    before { allow(action_stub).to receive(:to_raise).and_call_original }

    it { is_expected.to eq action_stub }

    it "stubs invalid_argument" do
      expect(exception).to eq expected_error
    end

    it "sends the error to to_raise" do
      expect(action_stub).to have_received(:to_raise).with(exception)
    end
  end

  describe "#to_fail_with" do
    let(:failure) { action_stub.to_fail_with(code, message, **{ metadata: metadata }.compact) }
    let(:exception) { failure.response_sequence.first.responses.first.exception }

    let(:message) { Faker::ChuckNorris.fact }
    let(:metadata) { nil }

    shared_context "with metadata" do
      let(:metadata) { Hash[*Faker::Lorem.unique.words(number: 4).map(&:to_sym)] }
    end

    before { allow(action_stub).to receive(:to_raise).and_call_original }

    context "with no error code" do
      subject(:failure) { action_stub.to_fail_with }

      let(:expected_error) { GRPC::InvalidArgument.new("unknown cause", metadata) }

      it { is_expected.to eq action_stub }

      it "stubs invalid_argument" do
        expect(exception).to eq expected_error
      end

      it "sends the error to to_raise" do
        expect(action_stub).to have_received(:to_raise).with(exception)
      end

      context "with metadata" do
        subject(:failure) { action_stub.to_fail_with(metadata: metadata) }

        include_context "with metadata"

        it "has the correct metadata" do
          expect(exception.metadata).to eq metadata
        end
      end
    end

    context "with a valid failure code" do
      let(:expected_error) { GRPC.const_get(code.camelize).new(message, metadata) }
      let(:code) { %w[invalid_argument not_found unauthenticated].sample }

      it "returns itself" do
        expect(failure).to equal action_stub
      end

      it "stubs the response with the expected error" do
        expect(exception).to eq expected_error
      end

      it "sends the error to to_raise" do
        expect(action_stub).to have_received(:to_raise).with(exception)
      end

      context "with metadata" do
        include_context "with metadata"

        it "has the correct metadata" do
          expect(exception.metadata).to eq metadata
        end
      end
    end

    context "with an invalid failure code" do
      let(:code) { Faker::Lorem.word }

      it "raises an ArgumentError" do
        expect { failure }.to raise_error(ArgumentError, "'#{code}' is not a valid gRPC failure code")
      end

      context "with a non-failure (but existing) constant name" do
        let(:code) do
          GRPC.constants.reject do |name|
            GRPC.const_get(name).then { |c| !c.is_a?(Class) || c < GRPC::BadStatus }
          end.sample
        end

        it "raises an ArgumentError" do
          expect { failure }.to raise_error(ArgumentError, "'#{code}' is not a valid gRPC failure code")
        end
      end
    end
  end

  describe "#match?" do
    subject { action_stub.match?(path, match_request) }

    let(:path) { "/#{service_name}/#{endpoint.to_s.camelize}" }
    let(:match_request) { input_class.new }


    context "when not stubbed with request" do
      context "with the same path" do
        it { is_expected.to be true }
      end

      context "with a different path" do
        let(:path) { Faker::ChuckNorris.fact }

        it { is_expected.to be false }
      end
    end

    context "when stubbed with request" do
      let(:stubbed_request) { input_class.new(msg: stub_message) }
      let(:stub_message) { Faker::Hipster.sentence }
      let(:match_message) { stub_message }

      before { action_stub.with(stubbed_request) }

      context "with a different path" do
        let(:path) { Faker::ChuckNorris.fact }

        it { is_expected.to be false }
      end

      context "with the same path" do
        context "with proto" do
          let(:match_request) { input_class.new(msg: match_message) }

          context "with matching parameters" do
            it { is_expected.to be true }
          end

          context "with different parameters" do
            let(:match_message) { Faker::Lorem.sentence }

            it { is_expected.to be false }
          end
        end

        context "with hash" do
          let(:match_request) { { msg: match_message } }

          context "with matching parameters" do
            it { is_expected.to be true }
          end

          context "with different parameters" do
            let(:match_message) { Faker::Lorem.sentence }

            it { is_expected.to be false }
          end
        end
      end
    end
  end
end
