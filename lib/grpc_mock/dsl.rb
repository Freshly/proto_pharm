# frozen_string_literal: true

module GrpcMock
  module DSL
    delegate :stub_grpc_action, to: :grpc_mock

    private

    def grpc_mock
      ::GrpcMock
    end
  end
end
