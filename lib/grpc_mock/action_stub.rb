# frozen_string_literal: true

module GrpcMock
  class ActionStub < RequestStub
    # @param path [String] gRPC path like /${service_name}/${method_name}
    # @param rpc_action [GRPC::RpcDesc] instance with parameters like +name+, +input+, +output+ and others
    def initialize(path, rpc_action)
      @rpc_action = rpc_action
      super(path)
    end

    # @param request [Hash] a list of parameters for request
    def with(**request)
      super(@rpc_action.input.new(request))
    end

    # @param responses [Array<Hash>] one or list of response objects
    def to_return(*responses)
      values = [*responses].flatten.map { |v| @rpc_action.output.new(v) }
      super(values)
    end
  end
end
