# frozen_string_literal: true

RSpec.describe ProtoPharm::Introspection::RpcInspector do
  subject(:inspector) { described_class.new(grpc_service, endpoint_name) }

  let(:grpc_service) { Hello::Hello }
  let(:endpoint_name) { :hello }
  let(:rpc_desc) { grpc_service::Service.rpc_descs[endpoint_name.to_s.camelize.to_sym] }

  describe "#normalize_request_proto" do
    let(:param_hash) { { msg: "hola" } }

    context "with kwargs" do
      subject { inspector.normalize_request_proto(param_hash) }

      it { is_expected.to eq inspector.input_type.new(param_hash) }
    end

    context "with a hash" do
      subject { inspector.normalize_request_proto(**param_hash) }

      it { is_expected.to eq inspector.input_type.new(param_hash) }
    end

    context "with a proto" do
      subject(:normalized_proto) { inspector.normalize_request_proto(proto) }

      context "with the correct proto class" do
        let(:proto) { inspector.input_type.new(param_hash) }

        it { is_expected.to equal proto }
      end

      context "with the wrong proto class" do
        let(:proto) { inspector.output_type.new(param_hash) }

        it "raises" do
          expect { normalized_proto }.to raise_error ProtoPharm::InvalidProtoType
        end
      end
    end
  end

  describe "#normalize_response_proto" do
    let(:param_hash) { { msg: "adiós" } }

    context "with kwargs" do
      subject { inspector.normalize_response_proto(param_hash) }

      it { is_expected.to eq inspector.output_type.new(param_hash) }
    end

    context "with a hash" do
      subject { inspector.normalize_response_proto(**param_hash) }

      it { is_expected.to eq inspector.output_type.new(param_hash) }
    end

    context "with a proto" do
      subject(:normalized_proto) { inspector.normalize_response_proto(proto) }

      context "with the correct proto class" do
        let(:proto) { inspector.output_type.new(param_hash) }

        it { is_expected.to equal proto }
      end

      context "with the wrong proto class" do
        let(:proto) { inspector.input_type.new(param_hash) }

        it "raises" do
          expect { normalized_proto }.to raise_error ProtoPharm::InvalidProtoType
        end
      end
    end
  end

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
