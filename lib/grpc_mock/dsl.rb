# frozen_string_literal: true

require 'active_support/core_ext/module'

module GrpcMock
  module DSL
    delegate :stub_grpc_action, to: :grpc_mock

    private

    def grpc_mock
      ::GrpcMock
    end
  end
end
