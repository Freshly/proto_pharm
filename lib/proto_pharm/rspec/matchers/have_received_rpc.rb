# frozen_string_literal: true

module ProtoPharm
  module RSpec
    module Matchers
        extend ::RSpec::Matchers::DSL

      matcher :have_received_rpc do |endpoint_reference| # rubocop:disable Metrics/BlockLength
        include Introspection

        attr_reader :service_reference, :endpoint_reference, :expected_proto, :expected_kwargs

        description { "receive rpc #{endpoint_reference.inspect}#{with_parameters_description}" }

        match do |service_reference|
          @service_reference = service_reference
          @endpoint_reference = endpoint_reference

          raise RpcNotStubbedError, "RPC '#{grpc_path}' has not been stubbed. Stub it with stub_grpc_action before asserting." unless matching_request_stubs.any?

          if expected_request_proto.blank?
            expect(received_request_stubs.size).to be > 0
          else
            expect(received_request_stubs.flat_map(&:received_requests)).to include expected_request_proto
          end
        end

        chain :with do |expected_proto = nil, **expected_kwargs|
          raise ArgumentError, "assert only with proto or keyword arguments, not both" if expected_proto.present? && expected_kwargs.present?
          raise ArgumentError, "cannot assert expected arguments multiple times in the same expectation" if (@expected_proto || @expected_kwargs).present?

          @expected_proto = expected_proto
          @expected_kwargs = expected_kwargs
        end

        private

        delegate :grpc_path, :input_type, to: :endpoint

        def endpoint
          @endpoint ||= inspect_rpc(service_reference, endpoint_reference)
        end

        def received_request_stubs
          matching_request_stubs.select { |stub| stub.received_count > 0 }
        end

        def matching_request_stubs
          @matching_request_stubs ||= ProtoPharm.stub_registry.all_requests_matching(grpc_path, expected_request_proto)
        end

        def expected_request_proto
          return if expected_proto.nil? && expected_kwargs.nil?

          ensure_valid_proto_type!(expected_proto)

          @expected_request_proto ||= expected_proto.presence || input_type.new(**expected_kwargs)
        end

        def ensure_valid_proto_type!(expected_proto)
          raise InvalidProtoType, "Invalid proto type #{expected_proto.class} for #{grpc_path}, expected #{input_type}" if expected_proto.present? && expected_proto.class != input_type
        end

        def with_parameters_description
          return if expected_request_proto.blank?

          " with request #{expected_request_proto.inspect}"
        end
      end
    end
  end
end
