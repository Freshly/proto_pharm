# frozen_string_literal: true

module ProtoPharm
  module RSpec
    class ActionStubBuilder
      attr_accessor :grpc_service, :action_stub_proxy

      delegate :rpc_action, :expectations, to: :action_stub_proxy

      def initialize(grpc_service)
        @grpc_service = grpc_service
      end

      def to(action_stub_proxy)
        @action_stub_proxy = action_stub_proxy

        ProtoPharm.stub_registry.register_request_stub(action_stub)
      end

      private

      def action_stub
        @action_stub ||= ActionStub.new(grpc_service, rpc_action).tap do |stub|
          expectations.each do |ex|
            if ex.kwargs.blank?
              stub.public_send(ex.method, *ex.args)
            elsif ex.args.blank?
              stub.public_send(ex.method, **ex.kwargs)
            else
              stub.public_send(ex.method, *ex.args, **ex.kwargs)
            end
          end
        end
      end
    end
  end
end
