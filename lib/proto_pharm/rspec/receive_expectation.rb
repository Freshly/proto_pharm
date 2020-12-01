# frozen_string_literal: true

module ProtoPharm
  module RSpec
    class ReceiveExpectation
      attr_reader :rpc_action, :stubbed_arguments, :responses

      def initialize(rpc_action)
        @rpc_action = rpc_action
        @responses = []
      end

      def with(proto = nil, **kwargs)
        raise ArgumentError, "cannot stub with both a proto and kwargs" if proto.present? && kwargs.present?
        raise ArgumentError, "must specify an expected request value" if proto.blank? && kwargs.empty?
        raise ArgumentError, "stubbed request value has already been stubbed as #{stubbed_arguments}" unless stubbed_arguments.nil?

        @stubbed_arguments = proto || kwargs

        self
      end

      def and_return(proto = nil, **kwargs)
        raise ArgumentError, "cannot stub with both a proto and kwargs" if proto.present? && kwargs.present?
        raise ArgumentError, "must specify a return value" if proto.blank? && kwargs.empty?

        responses << SuccessResponse.new(proto || kwargs)

        self
      end

      def and_raise(exception)
        responses << ExceptionResponse.new(exception)

        self
      end

      # @param code [String, Symbol] A gRPC failure code, such as not_found or invalid_argument. Default: :invalid_argument
      # @param message [String] A message to pass back with the exception
      # @param metadata [Hash] A hash of metadata to be passed back with the exception
      def and_fail_with(code = :invalid_argument, message = nil, metadata: {})
        responses << GrpcFailureResponse.new(code, message, metadata)

        self
      end

      class SuccessResponse
        attr_reader :value

        def initialize(value)
          @value = value
        end
      end

      class ExceptionResponse
        attr_reader :exception

        def initialize(exception)
          @exception = exception
        end
      end

      class GrpcFailureResponse
        attr_reader :code, :message, :metadata

        def initialize(code, message, metadata)
          @code = code
          @message = message
          @metadata = metadata
        end
      end
    end
  end
end
