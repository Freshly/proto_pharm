# frozen_string_literal: true

require 'proto_pharm/grpc_stub_adapter'

module ProtoPharm
  class Adapter
    def enable!
      adapter.enable!
    end

    def disable!
      adapter.disable!
    end

    private

    def adapter
      @adapter ||= GrpcStubAdapter.new
    end
  end
end
