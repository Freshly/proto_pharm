# frozen_string_literal: true

require "proto_pharm/grpc_stub_adapter"

module ProtoPharm
  class Adapter
    delegate :enable!, :disable!, to: :adapter

    private

    def adapter
      @adapter ||= GrpcStubAdapter.new
    end
  end
end
