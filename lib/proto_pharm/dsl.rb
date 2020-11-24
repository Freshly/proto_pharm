# frozen_string_literal: true

require 'active_support/core_ext/module'

module GrpcMock
  module DSL
    delegate :stub_grpc_action, to: :proto_pharm

    private

    def proto_pharm
      ::GrpcMock
    end
  end
end
