# frozen_string_literal: true

require 'grpc'
require 'proto_pharm/errors'
require 'proto_pharm/operation_stub'

module ProtoPharm
  class GrpcStubAdapter
    module MockStub
      def request_response(method, request, *args, **opts)
        return super unless ProtoPharm::GrpcStubAdapter.enabled?

        mock = ProtoPharm.stub_registry.response_for_request(method, request)

        if mock
          if opts[:return_op]
            OperationStub.new(response: mock.evaluate, metadata: opts[:metadata])
          else
            mock.evaluate
          end
        elsif ProtoPharm.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      # TODO
      def client_streamer(method, requests, *args)
        unless ProtoPharm::GrpcStubAdapter.enabled?
          return super
        end

        r = requests.to_a       # FIXME: this may not work
        mock = ProtoPharm.stub_registry.response_for_request(method, r)
        if mock
          mock.evaluate
        elsif ProtoPharm.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def server_streamer(method, request, *args)
        unless ProtoPharm::GrpcStubAdapter.enabled?
          return super
        end

        mock = ProtoPharm.stub_registry.response_for_request(method, request)
        if mock
          mock.evaluate
        elsif ProtoPharm.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def bidi_streamer(method, requests, *args)
        unless ProtoPharm::GrpcStubAdapter.enabled?
          return super
        end

        r = requests.to_a       # FIXME: this may not work
        mock = ProtoPharm.stub_registry.response_for_request(method, r)
        if mock
          mock.evaluate
        elsif ProtoPharm.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end
    end

    def self.disable!
      @enabled = false
    end

    def self.enable!
      @enabled = true
    end

    def self.enabled?
      @enabled
    end

    def enable!
      ProtoPharm::GrpcStubAdapter.enable!
    end

    def disable!
      ProtoPharm::GrpcStubAdapter.disable!
    end
  end
end