# frozen_string_literal: true

module ProtoPharm
  module RSpec
    module DSL
      def allow_grpc_service(service)
        ServiceStubProxy.new(service)
      end

      def receive_rpc(rpc_action)
        ReceiveExpectation.new(rpc_action)
      end
    end
  end
end
