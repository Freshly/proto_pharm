# frozen_string_literal: true

require "directive"
require_relative "metadata_serializers/base"
require_relative "metadata_serializers/gruf"
# require_relative "metadata_serializers/freshly"

module ProtoPharm
  module Configuration
    extend Directive

    configuration_options do
      option :metadata_serializer, default: MetadataSerializers::Base
    end
  end
end
