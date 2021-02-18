# frozen_string_literal: true

# Serializes metadata for an application's Gruf configuration.
#
# Usage:
#  Configuration.configure { |c| c.metadata_serializer = ProtoPharm::MetadataSerializers::Gruf }
#
#  allow_grpc_service(AService)
#    .to receive_rpc(:your_endpoint)
#    .and_fail_with(
#      code: :invalid_argument,
#      app_code: :cant_let_you_do_that_star_fox
#      metadata: { some: :meta }
#    )
#
# begin
#   Service.your_endpoint
# rescue Gruf::Client::Error::InvalidArgument => e
#   e.error
module ProtoPharm
  module MetadataSerializers
    module Gruf
      class << self
        def serialize(code:, app_code: nil, **metadata)
          {
            **metadata.fetch(:metadata, {}),
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
