# frozen_string_literal: true

module ProtoPharm
  module RSpec
    class ServiceStubProxy
      attr_accessor :grpc_service, :expectation

      def initialize(grpc_service)
        @grpc_service = grpc_service
      end

      def to(expectation)
        @expectation = expectation

        setup_action_stub!
        register_action_stub!
      end

      private

      def setup_action_stub!
        raise ArgumentError, "use method :receive_rpc to stub grpc services" unless expectation.is_a?(ReceiveExpectation)

        setup_stub_request!
        setup_stub_responses!
        register_action_stub!
      end

      def setup_stub_request!
        action_stub.with(expectation.stubbed_arguments) unless expectation.stubbed_arguments.nil?
      end

      def setup_stub_responses!
        expectation.responses.each do |response|
          case response
          when ReceiveExpectation::SuccessResponse
            action_stub.to_return(response.value)
          when ReceiveExpectation::ExceptionResponse
            action_stub.to_raise(response.exception)
          when ReceiveExpectation::GrpcFailureResponse
            action_stub.to_fail_with(response.code, response.message, metadata: response.metadata)
          end
        end
      end

      def register_action_stub!
        ProtoPharm.stub_registry.register_request_stub(action_stub)
      end

      def action_stub
        @action_stub ||= ActionStub.new(grpc_service, expectation.rpc_action)
      end
    end
  end
end
