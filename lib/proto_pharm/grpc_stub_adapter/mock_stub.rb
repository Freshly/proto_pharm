# frozen_string_literal: true

module ProtoPharm
  class GrpcStubAdapter
    module MockStub
      class << self
        attr_accessor :allow_net_connect
      end

      def request_response(method, request, *args, return_op: false, **opts)
        return super unless ProtoPharm.enabled?

        request_stub = ProtoPharm.stub_registry.find_request_matching(method, request)

        if request_stub
          operation = OperationStub.new(metadata: opts[:metadata]) do
            request_stub.received!(request)
            request_stub.response.evaluate
          end

          return_op ? operation : operation.execute
        elsif _allow_net_connect?
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      # TODO
      def client_streamer(method, requests, *args)
        return super unless ProtoPharm.enabled?

        r = requests.to_a       # FIXME: this may not work
        request_stub = ProtoPharm.stub_registry.find_request_matching(method, r)

        if request_stub
          request_stub.received!(requests)
          request_stub.response.evaluate
        elsif _allow_net_connect?
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def server_streamer(method, request, *args)
        return super unless ProtoPharm.enabled?

        request_stub = ProtoPharm.stub_registry.find_request_matching(method, request)

        if request_stub
          request_stub.received!(request)
          request_stub.response.evaluate
        elsif _allow_net_connect?
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def bidi_streamer(method, requests, *args)
        return super unless ProtoPharm.enabled?

        r = requests.to_a       # FIXME: this may not work
        request_stub = ProtoPharm.stub_registry.find_request_matching(method, r)

        if request_stub
          request_stub.received!(requests)
          request_stub.response.evaluate
        elsif _allow_net_connect?
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      private

      def _allow_net_connect?
        ProtoPharm::GrpcStubAdapter::MockStub.allow_net_connect == true
      end
    end
  end
end
