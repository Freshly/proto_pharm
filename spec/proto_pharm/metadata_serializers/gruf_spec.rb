# frozen_string_literal: true

require "gruf"

RSpec.describe ProtoPharm::MetadataSerializers::Gruf do
  describe ".serialize" do
    subject(:serialize) { described_class.serialize(**input) }

    let(:input) { { code: code, app_code: app_code, message: message } }

    let(:code) { GRPC::Core::StatusCodes.constants.sample.to_s.underscore }
    let(:app_code) { Faker::Lorem.words.join("_") }
    let(:message) { Faker::ChuckNorris.fact }
    let(:metadata) { {} }
    let(:field_errors) { [] }

    let(:gruf_metadata_key) { Gruf.error_metadata_key }
    let(:serialized_gruf_metadata) do
      {
        code: code,
        app_code: app_code,
        message: message,
        field_errors: field_errors,
        debug_info: {},
      }.to_json
    end
    let(:expected_response) do
      metadata.transform_values(&:to_s).merge(
        gruf_metadata_key => serialized_gruf_metadata,
      )
    end

    context "when Gruf is not defined" do
      before { hide_const("Gruf") }

      it "raise NameError" do
        expect { serialize }.to raise_error NameError, "uninitialized constant Gruf"
      end
    end

    context "when app_code is blank" do
      let(:app_code) { nil }

      before { input.compact! }

      it { is_expected.to eq expected_response }
    end

    context "when message is blank" do
      let(:message) { nil }

      before { input.compact! }

      it { is_expected.to eq expected_response }
    end

    context "when :metadata key is present" do
      before { input.merge!(metadata: metadata) }

      context "when given metadata is a string" do
        let(:metadata) { Faker::ChuckNorris.fact }

        it "raises" do
          expect { serialize }.to raise_error TypeError
        end
      end

      context "when given metadata is a hash" do
        let(:metadata) { Hash[*Faker::Lorem.unique.words(number: 4)].symbolize_keys }

        it { is_expected.to eq expected_response }
      end
    end

    context "when :metadata key is not present" do
      let(:another_key) { Faker::Lorem.sentence.parameterize.underscore.to_sym }
      let(:another_value) { Faker::ChuckNorris.fact }

      before { input.merge!(another_key => another_value) }

      it { is_expected.to eq expected_response }
    end

    context "with field errors" do
      let(:field_name) { Faker::Lorem.unique.word }
      let(:error_code) { Faker::Hipster.word }
      let(:message) { Faker::ChuckNorris.fact }
      let(:field_error) do
        {
          field_name: field_name,
          error_code: error_code,
          message: message,
        }
      end
      let(:field_errors) { [ field_error ] }

      before { input.merge!(field_errors: [ field_error ]) }

      it { is_expected.to eq expected_response }
    end
  end
end
