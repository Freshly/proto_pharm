# frozen_string_literal: true

RSpec.describe ProtoPharm::Introspection::ServiceResolver do
  describe ".resolve" do
    subject(:resolve) { described_class.resolve(input) }

    context "when input is a gRPC GenericService class" do
      let(:input) { Hello::Hello::Service }

      it { is_expected.to equal input }
    end

    context "when input is a service wrapper module" do
      let(:input) { Hello::Hello }

      it { is_expected.to equal input::Service }
    end

    context "when input is a symbol" do
      let(:input) { :hello_service }

      it "raises" do
        expect { resolve }.to raise_error described_class::InvalidGRPCServiceError
      end
    end

    context "when input is nil" do
      let(:input) { nil }

      it "raises" do
        expect { resolve }.to raise_error described_class::InvalidGRPCServiceError
      end
    end
  end
end
