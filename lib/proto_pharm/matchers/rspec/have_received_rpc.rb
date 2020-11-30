# frozen_string_literal: true

module ProtoPharm
  module Matchers
    module RSpec
      extend ::RSpec::Matchers::DSL

      matcher :have_received_rpc do |endpoint_token| # rubocop:disable Metrics/BlockLength
        include Introspection

        attr_reader :service_token, :endpoint_token, :expected_proto, :expected_kwargs


        match do |service_token|
          @service_token = service_token
          @endpoint_token = endpoint_token

          raise RpcNotStubbedError, "RPC '#{grpc_path}' has not been stubbed. Stub it with stub_grpc_action before asserting." unless matching_request_stubs.any?

          expect(received_request_stubs.size).to be > 0
        end


        private

        delegate :grpc_path, :input_type, :output_type, to: :endpoint

        def endpoint
          @endpoint ||= inspect_rpc(service_token, endpoint_token)
        end

        def received_request_stubs
          matching_request_stubs.select { |stub| stub.received_count > 0 }
        end

        def matching_request_stubs
          @matching_request_stubs ||= ProtoPharm.stub_registry.all_requests_matching(*[ grpc_path, expected_request_proto ].compact)
        end

        def expected_request_proto
          return if expected_proto.nil? && expected_kwargs.nil?
        end
      end
    end
  end
end
