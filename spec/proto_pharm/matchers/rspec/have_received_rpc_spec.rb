# frozen_string_literal: true

require "proto_pharm/rspec"

RSpec.describe ProtoPharm::Matchers::RSpec do
  describe "#have_received_rpc" do
    subject(:assertion) { expect(service).to have_received_rpc(endpoint) }

    let(:client) { HelloClient.new }
    let(:message) { "Hi!" }

    let(:service) { Hello::Hello }
    let(:endpoint) { :hello }

    let(:request) { {} }
    let(:response) { {} }

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
        before { client.send_message(message) }

        it { is_expected.to have_received_rpc(endpoint) }
      end
    end
  end
end
