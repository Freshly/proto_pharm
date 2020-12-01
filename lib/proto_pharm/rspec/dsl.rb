# frozen_string_literal: true

module ProtoPharm
  module RSpec
    module DSL
      delegate :stub_grpc_action, to: :proto_pharm

      def allow_grpc_service(service)
        ServiceStub.new(service)
      end

      private

      def proto_pharm
        ::ProtoPharm
      end
    end
  end
end
