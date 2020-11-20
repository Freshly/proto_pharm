# frozen_string_literal: true

module GrpcMock
  class ActionStub < RequestStub
    attr_reader :rpc_action

    # @param path [String] gRPC path like /${service_name}/${method_name}
    # @param rpc_action [GRPC::RpcDesc] instance with parameters like +name+, +input+, +output+ and others
    def initialize(path, rpc_action)
      @rpc_action = rpc_action

      super(path)
    end

    # @param proto [Object] request proto object
    # @param request [Hash] parameters for request
    def with(proto = nil, **request)
      proto ? super(proto) : super(rpc_action.input.new(request))
    end

    # @param proto [Object] response proto object
    # @param response [Hash] parameters to respond with
    def to_return(proto = nil, **response)
      proto ? super(proto) : super(rpc_action.output.new(response))
    end
  end
end
