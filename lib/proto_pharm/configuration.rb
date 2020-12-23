# frozen_string_literal: true

require "directive"
require_relative "metadata_serializers/base"

module ProtoPharm
  module Configuration
    extend Directive

    configuration_options do
      option :metadata_serializer, default: MetadataSerializers::Base
    end
  end
end
