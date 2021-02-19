# frozen_string_literal: true

module ProtoPharm
  module MetadataSerializers
    module Freshly
      class << self
        def serialize(code:, app_code: nil, **kwargs)
          metadata = kwargs.fetch(:metadata, {})

          {
            metadata: metadata,
          }.tap do |hash|
            if ::Gruf.append_server_errors_to_trailing_metadata
              enc_metadata = Labyrinth::GrufComponents::ErrorSerializer.encoded_metadata_hash(metadata)

              e = ::Gruf::Error.new(code: code, app_code: app_code, metadata: enc_metadata)
              hash[::Gruf.error_metadata_key.to_sym] = e.serialize
            end
          end
        end
      end
    end
  end
end
