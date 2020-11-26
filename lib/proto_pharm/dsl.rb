# frozen_string_literal: true

module ProtoPharm
  module DSL
    delegate :stub_grpc_action, to: :proto_pharm

    private

    def proto_pharm
      ::ProtoPharm
    end
  end
end
