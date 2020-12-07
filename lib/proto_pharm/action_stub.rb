# frozen_string_literal: true

require "active_support/core_ext/object/blank"

module ProtoPharm
  class ActionStub < RequestStub
    include Introspection
    include StubComponents::FailureResponse

    attr_reader :service, :action

    # @param service [GRPC::GenericService] gRPC service class representing the the service being stubbed
    # @param action [String, Symbol] name of the endpoint being stubbed
    def initialize(service, action)
      @service = service
      @action = action

      super(grpc_path)
    end

    # @param proto [Object] request proto object
    # @param request_kwargs [Hash] parameters for request
    def with(proto = nil, **request_kwargs)
      super(endpoint.normalize_request_proto(proto, **request_kwargs))
    end

    # @param proto [Object] response proto object
    # @param request_kwargs [Hash] parameters to respond with
    def to_return(proto = nil, **request_kwargs)
      super(endpoint.normalize_response_proto(proto, **request_kwargs))
    end

    def received!(request)
      @received_requests << request
    end

    def received_count
      received_requests.size
    end

    def match?(match_path, match_request)
      # If paths don't match, don't try to cast the request object
      super unless grpc_path == match_path

      # If paths match, cast the given request object to the expected proto
      super(match_path, endpoint.normalize_request_proto(match_request))
    end

    private

    delegate :grpc_path, :input_type, :output_type, to: :endpoint

    def endpoint
      @endpoint ||= inspect_rpc(service, action)
    end
  end
end
