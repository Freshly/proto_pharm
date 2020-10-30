# frozen_string_literal: true

module GrpcMock
  module DSL
    def stub_grpc_action(path, rpc_action)
      GrpcMock.stub_registry.register_request_stub(GrpcMock::ActionStub.new(path, rpc_action))
    end
  end
end
