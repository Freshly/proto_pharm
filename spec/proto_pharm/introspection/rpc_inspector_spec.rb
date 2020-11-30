# frozen_string_literal: true

RSpec.describe ProtoPharm::Introspection::RpcInspector do
  subject(:inspector) { described_class.new(grpc_service, endpoint_name) }

  let(:grpc_service) { Hello::Hello }
  let(:endpoint_name) { :hello }
  let(:rpc_desc) { grpc_service::Service.rpc_descs[endpoint_name.to_s.camelize.to_sym] }

  describe "#normalized_rpc_name" do
    subject { inspector.normalized_rpc_name }

    context "when endpoint name is underscored" do
      let(:endpoint_name) { :hello_stream }

      it { is_expected.to eq endpoint_name.to_s.camelize.to_sym }
    end

    context "when endpoint name is camelized" do
      let(:endpoint_name) { :HelloStream }

      it { is_expected.to eq endpoint_name }
    end
  end

  describe "#rpc_desc" do
    subject(:rpc_desc) { inspector.rpc_desc }

    context "when endpoint does not exist" do
      let(:endpoint_name) { :foo_your_bar }

      it "raises" do
        expect { rpc_desc }.to raise_error ProtoPharm::RpcNotFoundError
      end
    end

    context "when the endpoint exists" do
      context "when endpoint name is underscored" do
        let(:endpoint_name) { :hello_stream }

        it { is_expected.to equal rpc_desc }
      end

      context "when endpoint name is camelized" do
        let(:endpoint_name) { :HelloStream }

        it { is_expected.to equal rpc_desc }
      end
    end
  end

  describe "#grpc_path" do
    subject { inspector.grpc_path }

    let(:expected_path) { "/#{grpc_service::Service.service_name}/#{endpoint_name.to_s.camelize}" }

    context "when endpoint name is underscored" do
      let(:endpoint_name) { :hello_stream }

      it { is_expected.to eq expected_path }
    end

    context "when endpoint name is camelized" do
      let(:endpoint_name) { :HelloStream }

      it { is_expected.to eq expected_path }
    end
  end

  describe "#input_type" do
    subject { inspector.input_type }

    it { is_expected.to equal rpc_desc.input }
  end

  describe "#output_type" do
    subject { inspector.output_type }

    it { is_expected.to equal rpc_desc.output }
  end
end
