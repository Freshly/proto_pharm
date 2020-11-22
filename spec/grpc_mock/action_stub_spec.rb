# frozen_string_literal: true

require 'examples/hello/hello_services_pb'

RSpec.describe GrpcMock::ActionStub do
  subject(:action_stub) { described_class.new(service, endpoint) }

  let(:path) { "/#{service_name}/#{endpoint.to_s.camelize}" }

  let(:action) do
    double(input: input_class, output: output_class)
  end

  let(:service) { Hello::Hello::Service }
  let(:service_name) { service.service_name  }
  let(:endpoint) { :hello }

  let(:input_class) { Hello::HelloRequest }
  let(:output_class) { Hello::HelloResponse }

  describe '#response' do
    let(:exception) { StandardError.new }
    let(:value1) { { msg: "response 1" } }
    let(:value2) { { msg: "response 2" } }

    it 'returns response' do
      action_stub.to_return(value1)
      expect(action_stub.response.evaluate).to eq(output_class.new(value1))
    end

    it 'raises exception' do
      action_stub.to_raise(exception)
      expect { action_stub.response.evaluate }.to raise_error(StandardError)
    end

    it 'returns responses in a sequence passed as array with multiple to_return calling' do
      action_stub.to_return(value1)
      action_stub.to_return(value2)
      expect(action_stub.response.evaluate).to eq(output_class.new(value1))
      expect(action_stub.response.evaluate).to eq(output_class.new(value2))
    end

    it 'repeats returning last response' do
      action_stub.to_return(value1)
      action_stub.to_return(value2)
      expect(action_stub.response.evaluate).to eq(output_class.new(value1))
      expect(action_stub.response.evaluate).to eq(output_class.new(value2))
      expect(action_stub.response.evaluate).to eq(output_class.new(value2))
      expect(action_stub.response.evaluate).to eq(output_class.new(value2))
    end

    context 'when not calling #to_return' do
      it 'raises an error' do
        expect { action_stub.response }.to raise_error(GrpcMock::NoResponseError)
      end
    end
  end

  describe '#with' do
    context "when hash params" do
      let(:request) { { msg: "request" } }

      it 'registers request', aggregate: true do
        expect(input_class).to receive(:new).with(request).and_call_original

        expect(action_stub.with(request)).to eq(action_stub)
      end
    end

    context "when proto object" do
      let(:request) { :request }

      it 'registers request', aggregate: true do
        expect(input_class).not_to receive(:new).with(request)

        expect(action_stub.with(request)).to eq(action_stub)
      end
    end
  end

  describe '#to_return' do
    context "when hash params" do
      let(:response) { { msg: "response" } }

      it 'registers response', aggregate: true do
        expect(output_class).to receive(:new).with(response)

        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::Value]).once
        expect(action_stub.to_return(response)).to eq(action_stub)
      end
    end

    context "when proto object" do
      let(:response) { :response }

      it 'registers response', aggregate: true do
        expect(action).not_to receive(:output)
        expect(output_class).not_to receive(:new).with(response)

        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::Value]).once
        expect(action_stub.to_return(response)).to eq(action_stub)
      end
    end
  end

  describe '#to_raise' do
    context 'with string' do
      let(:exception) { 'string' }
      it 'registers exception' do
        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::ExceptionValue]).once
        expect(action_stub.to_raise(exception)).to eq(action_stub)
      end
    end

    context 'with class' do
      let(:response) { StandardError }
      it 'registers exception' do
        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::ExceptionValue]).once
        expect(action_stub.to_raise(response)).to eq(action_stub)
      end
    end

    context 'with exception instance' do
      let(:response) { StandardError.new('message') }
      it 'registers exception' do
        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::ExceptionValue]).once
        expect(action_stub.to_raise(response)).to eq(action_stub)
      end
    end

    context 'with invalid value (integer)' do
      let(:response) { 1 }
      it 'raises ArgumentError' do
        expect { action_stub.to_raise(response) }.to raise_error(ArgumentError)
      end
    end

    context 'with multi exceptions' do
      let(:exception) { StandardError.new('message') }
      it 'registers exceptions' do
        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::ExceptionValue, GrpcMock::Response::ExceptionValue]).once
        expect(action_stub.to_raise(exception, exception)).to eq(action_stub)
      end
    end
  end

  describe '#match?' do
    it { expect(action_stub).to be_match(path, double(:request)) }
  end
end
