# frozen_string_literal: true

module ProtoPharm
  module MetadataSerializers
    module Gruf
      class << self
        def serialize(code:, app_code: nil, **metadata)
          {
            metadata: metadata.fetch(:metadata, {}),
          }.tap do |hash|
            if ::Gruf.append_server_errors_to_trailing_metadata
              e = ::Gruf::Error.new(code: code, app_code: app_code, **metadata)
              hash[::Gruf.error_metadata_key.to_sym] = e.serialize
            end
          end
        end
      end
    end
  end
end
