# frozen_string_literal: true

require 'active_support/core_ext/object/blank'

module GrpcMock
  module StubComponents
    module FailureResponse
      def to_fail_with(code = :invalid_argument, message = nil, **metadata)
        to_raise(exception_class(code).new(message, metadata))
      end

      private

      def exception_class(code)
        class_name = code.to_s.camelize

        (GRPC.const_get(class_name) if GRPC.const_defined?(class_name)).tap do |klass|
          raise ArgumentError, "'#{code}' is not a valid gRPC failure code" unless klass.present? && klass < GRPC::BadStatus
        end
      end
    end
  end
end
