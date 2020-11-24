# frozen_string_literal: true

require 'examples/hello/hello_services_pb'

RSpec.describe GrpcMock::ActionStub do
  subject(:action_stub) { described_class.new(service, endpoint) }

  let(:service) { Hello::Hello::Service }
  let(:service_name) { service.service_name }
  let(:endpoint) { :hello }

  let(:input_class) { Hello::HelloRequest }
  let(:output_class) { Hello::HelloResponse }

  describe '#response' do
    let(:exception) { StandardError.new }
    let(:value1) { { msg: 'response 1' } }
    let(:value2) { { msg: 'response 2' } }

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
    before { allow(input_class).to receive(:new).and_call_original }

    context 'with a hash' do
      let(:request) { { msg: 'request' } }

      it 'registers request', aggregate: true do
        expect(action_stub.with(request)).to eq(action_stub)
        expect(input_class).to have_received(:new).with(request)
      end
    end

    context 'with kwargs' do
      let(:request) { { msg: 'Hello?' } }

      it 'registers request', aggregate: true do
        expect(action_stub.with(**request)).to eq(action_stub)
        expect(input_class).to have_received(:new).with(request)
      end
    end

    context 'with a proto object' do
      let(:request) { input_class.new(msg: 'hello?') }

      it 'registers request', aggregate: true do
        expect(action_stub.with(request)).to eq(action_stub)
      end

      context 'with wrong proto class' do
        let(:request) { output_class.new(msg: 'hello?') }

        it 'raises InvalidProtoType' do
          expect { expect(action_stub.with(request)) }.to raise_error described_class::InvalidProtoType
        end
      end
    end
  end

  describe '#to_return' do
    before { allow(GrpcMock::ResponsesSequence).to receive(:new).and_call_original }

    context 'with a hash' do
      let(:response) { { msg: 'Hello!' } }

      it 'registers response', aggregate: true do
        expect(output_class).to receive(:new).with(response)

        expect(action_stub.to_return(response)).to eq(action_stub)

        expect(GrpcMock::ResponsesSequence).to have_received(:new).with([GrpcMock::Response::Value]).once
      end
    end

    context 'with kwargs' do
      let(:response) { { msg: 'Hello!' } }
      it 'registers response', aggregate: true do
        expect(output_class).to receive(:new).with(**response)

        expect(action_stub.to_return(**response)).to eq(action_stub)

        expect(GrpcMock::ResponsesSequence).to have_received(:new).with([GrpcMock::Response::Value]).once
      end
    end

    context 'with a proto object' do
      let(:response) { output_class.new(msg: 'Hello!') }

      it 'registers response', aggregate: true do
        expect(output_class).not_to receive(:new).with(response)

        expect(action_stub.to_return(response)).to eq(action_stub)

        expect(GrpcMock::ResponsesSequence).to have_received(:new).with([GrpcMock::Response::Value]).once
      end

      context 'with wrong proto class' do
        let(:response) { input_class.new(msg: 'hello?') }

        it 'raises InvalidProtoType' do
          expect { expect(action_stub.to_return(response)) }.to raise_error described_class::InvalidProtoType
        end
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
    let(:path) { "/#{service_name}/#{endpoint.to_s.camelize}" }

    subject { action_stub.match?(path, double) }

    it { is_expected.to be true }
  end
end
