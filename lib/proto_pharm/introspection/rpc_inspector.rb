# frozen_string_literal: true

module ProtoPharm
  module Introspection
    class RpcInspector
      attr_reader :grpc_service, :endpoint_name

      delegate :service_name, :rpc_descs, to: :grpc_service

      def initialize(service, endpoint_name)
        @grpc_service = ServiceResolver.resolve(service)

        @endpoint_name = endpoint_name
      end

      def normalize_request_proto(proto = nil, **kwargs)
        cast_proto(input_type, proto, **kwargs)
      end

      def normalize_response_proto(proto = nil, **kwargs)
        cast_proto(output_type, proto, **kwargs)
      end

      def normalized_rpc_name
        @normalized_rpc_name ||= endpoint_name.to_s.camelize.to_sym
      end

      def rpc_desc
        @rpc_desc ||= rpc_descs[normalized_rpc_name].tap do |endpoint|
          raise RpcNotFoundError, "Service #{service_name} does not implement '#{normalized_rpc_name}'" if endpoint.blank?
        end
      end

      def grpc_path
        @grpc_path ||= "/#{service_name}/#{normalized_rpc_name}"
      end

      def input_type
        rpc_desc.input
      end

      def output_type
        rpc_desc.output
      end

      private

      def cast_proto(proto_class, proto = nil, **kwargs)
        return proto_class.new(**kwargs) if proto.blank?
        return proto_class.new(proto) if proto.respond_to?(:to_hash)

        raise InvalidProtoType, "Invalid proto type #{proto.class} for #{grpc_path}, expected #{proto_class}" unless proto.class == proto_class

        proto
      end
    end
  end
end
