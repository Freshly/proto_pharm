# frozen_string_literal: true

RSpec.describe ProtoPharm::MetadataSerializers::Base do
  describe ".serialize" do
    subject(:serialize) { described_class.serialize(**metadata) }

    let(:serialized_metadata) { double }

    context "when :metadata key is present" do
      let(:metadata) { { metadata: serialized_metadata } }

      it { is_expected.to eq serialized_metadata }
    end

    context "when :metadata key is not present" do
      let(:metadata) { { another_key: serialized_metadata } }

      it { is_expected.to eq({}) }
    end
  end
end
