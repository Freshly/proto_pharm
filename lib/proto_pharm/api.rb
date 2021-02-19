# frozen_string_literal: true

module ProtoPharm
  module Api
    # @param path [String]
    def stub_request(path)
      ProtoPharm.stub_registry.register_request_stub(ProtoPharm::RequestStub.new(path))
    end

    def stub_grpc_action(service, rpc_action)
      ProtoPharm.stub_registry.register_request_stub(ProtoPharm::ActionStub.new(service, rpc_action))
    end

    # @param values [Hash]
    def request_including(values)
      ProtoPharm::Matchers::RequestIncludingMatcher.new(values)
    end

    def disable_net_connect!
      GrpcStubAdapter::MockStub.disable_net_connect!
    end

    def allow_net_connect!
      GrpcStubAdapter::MockStub.allow_net_connect!
    end

    def allow_net_connect?
      GrpcStubAdapter::MockStub.allow_net_connect?
    end
  end
end
