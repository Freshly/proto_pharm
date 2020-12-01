# frozen_string_literal: true

module ProtoPharm
  module RSpec
    module DSL
      def allow_grpc_service(service)
        ActionStubBuilder.new(service)
      end

      def receive_rpc(rpc_action)
        ActionStubProxy.new(rpc_action)
      end
    end
  end
end
