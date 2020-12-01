# frozen_string_literal: true

require "proto_pharm/rspec"

RSpec.describe ProtoPharm::RSpec::Matchers do
  subject(:service) { Hello::Hello }

  let(:client) { HelloClient.new }
  let(:expected_message) { "Hi!" }
  let(:endpoint) { :hello }

  let(:request_proto_class) { service::Service.rpc_descs[endpoint.to_s.camelize.to_sym].input }
  let(:response) { {} }

  describe "#have_received_rpc" do
    subject(:assertion) { expect(service).to have_received_rpc(endpoint) }

    context "when endpoint is not stubbed" do
      it "raises" do
        expect { assertion }.to raise_error(ProtoPharm::RpcNotStubbedError)
      end
    end

    context "when endpoint is stubbed" do
      subject { service }

      before { stub_grpc_action(service, endpoint).to_return(response) }

      context "when the rpc has not been received" do
        it { is_expected.not_to have_received_rpc(endpoint) }
      end

      context "when the rpc has been received" do
        before { client.send_message(expected_message) }

        it { is_expected.to have_received_rpc(endpoint) }
      end
    end
  end

  describe "#with" do
    let(:input_proto) { request_proto_class.new(input_hash_parameters) }
    let(:input_hash_parameters) { { msg: expected_message } }

    shared_context "with proto parameter" do
      subject(:assertion) { expect(service).to have_received_rpc(endpoint).with(input_proto) }
    end

    shared_context "with hash parameter" do
      subject(:assertion) { expect(service).to have_received_rpc(endpoint).with(input_hash_parameters) }
    end

    shared_context "with kwargs" do
      subject(:assertion) { expect(service).to have_received_rpc(endpoint).with(**input_hash_parameters) }
    end

    before { stub_grpc_action(service, endpoint).to_return(response) }

    context "when called with proto and hash parameters" do
      subject(:assertion) { expect(service).to have_received_rpc(endpoint).with(input_proto, **input_hash_parameters) }

      it "raises" do
        expect { assertion }.to raise_error ArgumentError, "assert only with proto or keyword arguments, not both"
      end
    end

    context "when called multiple times" do
      subject(:assertion) { expect(service).to have_received_rpc(endpoint).with(input_proto).with(**input_hash_parameters) }

      it "raises" do
        expect { assertion }.to raise_error ArgumentError, "cannot assert expected arguments multiple times in the same expectation"
      end
    end

    context "when the rpc has not been received" do
      it { is_expected.not_to have_received_rpc(endpoint).with(input_proto) }
    end

    context "when the rpc has been received" do
      before { client.send_message(sent_message) }

      context "when the rpc has been received with the correct parameters" do
        let(:sent_message) { expected_message }

        it { is_expected.to have_received_rpc(endpoint).with(input_proto) }

        context "when rpc is also called with different parameters" do
          before { client.send_message("Ahoy!") }

          it { is_expected.to have_received_rpc(endpoint).with(input_proto) }
        end
      end

      context "when the rpc has been received with different parameters" do
        let(:sent_message) { "Hello!" }

        it { is_expected.not_to have_received_rpc(endpoint).with(input_proto) }
      end
    end
  end
end
