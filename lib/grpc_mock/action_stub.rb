# frozen_string_literal: true

require 'active_support/core_ext/module'
require 'active_support/core_ext/object'

module GrpcMock
  class ActionStub < RequestStub
    class InvalidProtoType < StandardError; end

    attr_reader :service, :action

    # @param path [String] gRPC path like /${service_name}/${method_name}
    # @param action [GRPC::RpcDesc] instance with parameters like +name+, +input+, +output+ and others
    def initialize(service, action)
      @service = service
      @action = action

      super(path)
    end

    # @param proto [Object] request proto object
    # @param request [Hash] parameters for request
    def with(proto = nil, **request)
      return super(input_type.new(**request)) if proto.blank?
      return super(input_type.new(**proto)) if proto.respond_to?(:to_hash)

      raise InvalidProtoType, "Invalid proto type #{proto.class} for #{path}, expected #{input_type}" unless proto.class == input_type

      super(proto)
    end

    # @param proto [Object] response proto object
    # @param response [Hash] parameters to respond with
    def to_return(proto = nil, **response)
      return super(output_type.new(**response)) if proto.blank?
      return super(output_type.new(**proto)) if proto.respond_to?(:to_hash)

      raise InvalidProtoType, "Invalid proto type #{proto.class} for #{path}, expected #{output_type}" unless proto.class == output_type

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

    def path
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
