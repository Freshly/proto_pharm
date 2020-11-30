# frozen_string_literal: true

RSpec.describe ProtoPharm::RequestStub do
  let(:stub_request) do
    described_class.new(path)
  end

  let(:path) do
    "/service_name/method_name"
  end

  describe "#received_count" do
    subject { stub_request.received_count }

    context "when request has not been received yet" do
      it { is_expected.to eq 0 }
    end

    context "when received! has been called once" do
      before { stub_request.received! }

      it { is_expected.to eq 1 }
    end

    context "when received! has been called more than once" do
      let(:received_count) { rand(2..10) }

      before { received_count.times { stub_request.received! }}

      it { is_expected.to eq received_count}
    end
  end

  describe "#received!" do
    subject(:received!) { stub_request.received! }

    context "when received! has not been called yet" do
      it { is_expected.to eq 1 }

      it "increments received_count" do
        received!
        expect(stub_request.received_count).to eq 1
      end
    end

    context "when received! has been called already" do
      let(:received_before_count) { rand(2..10) }

      before { received_before_count.times { stub_request.received! } }

      it { is_expected.to eq(received_before_count + 1)}

      it "increments received_count" do
        received!
        expect(stub_request.received_count).to eq(received_before_count + 1)
      end
    end
  end

  describe "#response" do
    let(:exception) { StandardError.new }
    let(:value1) { :response_1 }
    let(:value2) { :response_2 }
    let(:value3) { :response_3 }

    it "returns response" do
      stub_request.to_return(value1)
      expect(stub_request.response.evaluate).to eq(value1)
    end

    it "raises exception" do
      stub_request.to_raise(exception)
      expect { stub_request.response.evaluate }.to raise_error(StandardError)
    end

    it "returns responses in a sequence passed as array" do
      stub_request.to_return(value1, value2)
      expect(stub_request.response.evaluate).to eq(value1)
      expect(stub_request.response.evaluate).to eq(value2)
    end

    it "returns responses in a sequence passed as array with multiple to_return calling" do
      stub_request.to_return(value1, value2)
      stub_request.to_return(value3)
      expect(stub_request.response.evaluate).to eq(value1)
      expect(stub_request.response.evaluate).to eq(value2)
      expect(stub_request.response.evaluate).to eq(value3)
    end

    it "repeats returning last response" do
      stub_request.to_return(value1, value2)
      expect(stub_request.response.evaluate).to eq(value1)
      expect(stub_request.response.evaluate).to eq(value2)
      expect(stub_request.response.evaluate).to eq(value2)
      expect(stub_request.response.evaluate).to eq(value2)
    end

    context "when not calling #to_return" do
      it "raises an error" do
        expect { stub_request.response }.to raise_error(ProtoPharm::NoResponseError)
      end
    end
  end

  describe "#to_return" do
    let(:response) { double(:response) }

    it "registers response" do
      expect(ProtoPharm::ResponsesSequence).to receive(:new).with([ProtoPharm::Response::Value]).once
      expect(stub_request.to_return(response)).to eq(stub_request)
    end

    it "registers multi responses" do
      expect(ProtoPharm::ResponsesSequence).to receive(:new).with([ProtoPharm::Response::Value, ProtoPharm::Response::Value]).once
      expect(stub_request.to_return(response, response)).to eq(stub_request)
    end
  end

  describe "#to_raise" do
    context "with string" do
      let(:exception) { "string" }
      it "registers exception" do
        expect(ProtoPharm::ResponsesSequence).to receive(:new).with([ProtoPharm::Response::ExceptionValue]).once
        expect(stub_request.to_raise(exception)).to eq(stub_request)
      end
    end

    context "with class" do
      let(:response) { StandardError }
      it "registers exception" do
        expect(ProtoPharm::ResponsesSequence).to receive(:new).with([ProtoPharm::Response::ExceptionValue]).once
        expect(stub_request.to_raise(response)).to eq(stub_request)
      end
    end

    context "with exception instance" do
      let(:response) { StandardError.new("message") }
      it "registers exception" do
        expect(ProtoPharm::ResponsesSequence).to receive(:new).with([ProtoPharm::Response::ExceptionValue]).once
        expect(stub_request.to_raise(response)).to eq(stub_request)
      end
    end

    context "with invalid value (integer)" do
      let(:response) { 1 }
      it "raises ArgumentError" do
        expect { stub_request.to_raise(response) }.to raise_error(ArgumentError)
      end
    end

    context "with multi exceptions" do
      let(:exception) { StandardError.new("message") }
      it "registers exceptions" do
        expect(ProtoPharm::ResponsesSequence).to receive(:new).with([ProtoPharm::Response::ExceptionValue, ProtoPharm::Response::ExceptionValue]).once
        expect(stub_request.to_raise(exception, exception)).to eq(stub_request)
      end
    end
  end

  describe "#match?" do
    it { expect(stub_request.match?(path, double(:request))).to eq(true) }
  end
end
