# frozen_string_literal: true

module ProtoPharm
  module Introspection
    class RpcInspector
      class RpcNotFoundError < StandardError; end

      attr_reader :grpc_service, :endpoint_name

      delegate :service_name, :rpc_descs, to: :grpc_service

      def initialize(service, endpoint_name)
        @grpc_service = ServiceResolver.resolve(service)

        @endpoint_name = endpoint_name
      end

      def normalized_endpoint_name
        @normalized_endpoint_name ||= endpoint_name.to_s.camelize.to_sym
      end

      def rpc_desc
        @rpc_desc ||= rpc_descs[normalized_endpoint_name] do |endpoint|
          raise RpcNotFoundError, "Service #{service_token} does not implement '#{normalized_endpoint_name}'" if endpoint.blank?
        end
      end

      def grpc_path
        @grpc_path ||= "/#{service_name}/#{normalized_endpoint_name}"
      end

      def input_type
        rpc_desc.input
      end

      def output_type
        rpc_desc.output
      end
    end
  end
end
