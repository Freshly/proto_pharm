# frozen_string_literal: true

require "active_support/core_ext/object/blank"

require_relative "stub_components/failure_response"

module ProtoPharm
  class ActionStub < RequestStub
    include StubComponents::FailureResponse

    class InvalidProtoType < StandardError; end

    attr_reader :service, :action

    # @param service [GRPC::GenericService] gRPC service class representing the the service being stubbed
    # @param action [String, Symbol] name of the endpoint being stubbed
    def initialize(service, action)
      @service = service
      @action = action

      super(grpc_path)
    end

    # @param proto [Object] request proto object
    # @param request [Hash] parameters for request
    def with(proto = nil, **request)
      return super(input_type.new(**request)) if proto.blank?
      return super(input_type.new(**proto)) if proto.respond_to?(:to_hash)

      raise InvalidProtoType, "Invalid proto type #{proto.class} for #{grpc_path}, expected #{input_type}" unless proto.class == input_type

      super(proto)
    end

    # @param proto [Object] response proto object
    # @param response [Hash] parameters to respond with
    def to_return(proto = nil, **response)
      return super(output_type.new(**response)) if proto.blank?
      return super(output_type.new(**proto)) if proto.respond_to?(:to_hash)

      raise InvalidProtoType, "Invalid proto type #{proto.class} for #{grpc_path}, expected #{output_type}" unless proto.class == output_type

      super(proto)
    end

    private

    delegate :service_name, :rpc_descs, to: :grpc_service

    def grpc_service
      service.const_defined?(:Service) ? service::Service : service
    end

    def endpoint_name
      @endpoint_name ||= rpc_descs.key?(action) ? action : action.to_s.camelize.to_sym
    end

    def rpc_desc
      rpc_descs[endpoint_name]
    end

    def grpc_path
      "/#{service_name}/#{endpoint_name}"
    end

    def input_type
      rpc_desc.input
    end

    def output_type
      rpc_desc.output
    end
  end
end
