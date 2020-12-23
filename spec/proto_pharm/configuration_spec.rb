# frozen_string_literal: true

RSpec.describe ProtoPharm::Configuration, type: :configuration do
  it { is_expected.to define_config_option :metadata_serializer, default: ProtoPharm::MetadataSerializers::Base }
end
