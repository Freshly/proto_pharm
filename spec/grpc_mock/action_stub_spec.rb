# frozen_string_literal: true

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

  let(:input_class) { double }
  let(:output_class) { double }

  before do
    allow(input_class).to receive(:new) { |arg| arg }
    allow(output_class).to receive(:new) { |arg| arg }
  end

  describe '#response' do
    let(:exception) { StandardError.new }
    let(:value1) { :response_1 }
    let(:value2) { :response_2 }
    let(:value3) { :response_3 }

    it 'returns response' do
      stub_grpc_action.to_return(value1)
      expect(stub_grpc_action.response.evaluate).to eq(value1)
    end

    it 'raises exception' do
      stub_grpc_action.to_raise(exception)
      expect { stub_grpc_action.response.evaluate }.to raise_error(StandardError)
    end

    it 'returns responses in a sequence passed as array' do
      stub_grpc_action.to_return(value1, value2)
      expect(stub_grpc_action.response.evaluate).to eq(value1)
      expect(stub_grpc_action.response.evaluate).to eq(value2)
    end

    it 'returns responses in a sequence passed as array with multiple to_return calling' do
      stub_grpc_action.to_return(value1, value2)
      stub_grpc_action.to_return(value3)
      expect(stub_grpc_action.response.evaluate).to eq(value1)
      expect(stub_grpc_action.response.evaluate).to eq(value2)
      expect(stub_grpc_action.response.evaluate).to eq(value3)
    end

    it 'repeats returning last response' do
      stub_grpc_action.to_return(value1, value2)
      expect(stub_grpc_action.response.evaluate).to eq(value1)
      expect(stub_grpc_action.response.evaluate).to eq(value2)
      expect(stub_grpc_action.response.evaluate).to eq(value2)
      expect(stub_grpc_action.response.evaluate).to eq(value2)
    end

    context 'when not calling #to_return' do
      it 'raises an error' do
        expect { stub_grpc_action.response }.to raise_error(GrpcMock::NoResponseError)
      end
    end
  end

  describe '#to_return' do
    let(:response) { double(:response) }

    it 'registers response' do
      expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::Value]).once
      expect(stub_grpc_action.to_return(response)).to eq(stub_grpc_action)
    end

    it 'registers multi responses' do
      expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::Value, GrpcMock::Response::Value]).once
      expect(stub_grpc_action.to_return(response, response)).to eq(stub_grpc_action)
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
