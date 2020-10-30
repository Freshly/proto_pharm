# frozen_string_literal: true

require 'examples/hello/hello_services_pb'

RSpec.describe GrpcMock::ActionStub do
  let(:stub_grpc_action) do
    described_class.new(path, action)
  end

  let(:path) do
    '/service_name/method_name'
  end

  let(:action) do
    double(input: input_class, output: output_class)
  end

  let(:input_class) { Hello::HelloRequest }
  let(:output_class) { Hello::HelloResponse }

  describe '#response' do
    let(:exception) { StandardError.new }
    let(:value1) { { msg: "response 1" } }
    let(:value2) { { msg: "response 2" } }

    it 'returns response' do
      stub_grpc_action.to_return(value1)
      expect(stub_grpc_action.response.evaluate).to eq(output_class.new(value1))
    end

    it 'raises exception' do
      stub_grpc_action.to_raise(exception)
      expect { stub_grpc_action.response.evaluate }.to raise_error(StandardError)
    end

    it 'returns responses in a sequence passed as array with multiple to_return calling' do
      stub_grpc_action.to_return(value1)
      stub_grpc_action.to_return(value2)
      expect(stub_grpc_action.response.evaluate).to eq(output_class.new(value1))
      expect(stub_grpc_action.response.evaluate).to eq(output_class.new(value2))
    end

    it 'repeats returning last response' do
      stub_grpc_action.to_return(value1)
      stub_grpc_action.to_return(value2)
      expect(stub_grpc_action.response.evaluate).to eq(output_class.new(value1))
      expect(stub_grpc_action.response.evaluate).to eq(output_class.new(value2))
      expect(stub_grpc_action.response.evaluate).to eq(output_class.new(value2))
      expect(stub_grpc_action.response.evaluate).to eq(output_class.new(value2))
    end

    context 'when not calling #to_return' do
      it 'raises an error' do
        expect { stub_grpc_action.response }.to raise_error(GrpcMock::NoResponseError)
      end
    end
  end

  describe '#with' do
    context "when hash params" do
      let(:request) { { msg: "request" } }

      it 'registers request', aggregate: true do
        expect(action).to receive(:input)
        expect(input_class).to receive(:new).with(request).and_call_original

        expect(stub_grpc_action.with(request)).to eq(stub_grpc_action)
      end
    end

    context "when proto object" do
      let(:request) { :request }

      it 'registers request', aggregate: true do
        expect(action).not_to receive(:input)
        expect(input_class).not_to receive(:new).with(request)

        expect(stub_grpc_action.with(request)).to eq(stub_grpc_action)
      end
    end
  end

  describe '#to_return' do
    context "when hash params" do
      let(:response) { { msg: "response" } }

      it 'registers response', aggregate: true do
        expect(action).to receive(:output)
        expect(output_class).to receive(:new).with(response)

        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::Value]).once
        expect(stub_grpc_action.to_return(response)).to eq(stub_grpc_action)
      end
    end

    context "when proto object" do
      let(:response) { :response }

      it 'registers response', aggregate: true do
        expect(action).not_to receive(:output)
        expect(output_class).not_to receive(:new).with(response)

        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::Value]).once
        expect(stub_grpc_action.to_return(response)).to eq(stub_grpc_action)
      end
    end
  end

  describe '#to_raise' do
    context 'with string' do
      let(:exception) { 'string' }
      it 'registers exception' do
        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::ExceptionValue]).once
        expect(stub_grpc_action.to_raise(exception)).to eq(stub_grpc_action)
      end
    end

    context 'with class' do
      let(:response) { StandardError }
      it 'registers exception' do
        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::ExceptionValue]).once
        expect(stub_grpc_action.to_raise(response)).to eq(stub_grpc_action)
      end
    end

    context 'with exception instance' do
      let(:response) { StandardError.new('message') }
      it 'registers exception' do
        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::ExceptionValue]).once
        expect(stub_grpc_action.to_raise(response)).to eq(stub_grpc_action)
      end
    end

    context 'with invalid value (integer)' do
      let(:response) { 1 }
      it 'raises ArgumentError' do
        expect { stub_grpc_action.to_raise(response) }.to raise_error(ArgumentError)
      end
    end

    context 'with multi exceptions' do
      let(:exception) { StandardError.new('message') }
      it 'registers exceptions' do
        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::ExceptionValue, GrpcMock::Response::ExceptionValue]).once
        expect(stub_grpc_action.to_raise(exception, exception)).to eq(stub_grpc_action)
      end
    end
  end

  describe '#match?' do
    it { expect(stub_grpc_action.match?(path, double(:request))).to eq(true) }
  end
end
