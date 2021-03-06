# frozen_string_literal: true

module ProtoPharm
  module StubComponents
    module FailureResponse
      # @param code [String, Symbol] A gRPC failure code, such as not_found or invalid_argument. Default: :invalid_argument
      # @param message [String] A message to pass back with the exception
      # @param metadata [Hash] A hash of metadata to be passed back with the exception. See {ProtoPharm::MetadataSerializers::Base.serialize}.
      def to_fail_with(code = :invalid_argument, message = "unknown cause", **metadata)
        to_raise(exception_class(code).new(message, metadata_serializer.serialize(code: code, message: message, **metadata)))
      end

      def to_fail
        to_fail_with
      end

      private

      def metadata_serializer
        Configuration.config.metadata_serializer
      end

      def exception_class(code)
        class_name = code.to_s.camelize

        (GRPC.const_get(class_name) if GRPC.const_defined?(class_name)).tap do |klass|
          raise ArgumentError, "'#{code}' is not a valid gRPC failure code" unless klass.present? && klass < GRPC::BadStatus
        end
      end
    end
  end
end
