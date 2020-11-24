# frozen_string_literal: true

require 'proto_pharm/api'
require 'proto_pharm/version'
require 'proto_pharm/configuration'
require 'proto_pharm/adapter'
require 'proto_pharm/stub_registry'

module ProtoPharm
  extend ProtoPharm::Api

  class << self
    def enable!
      adapter.enable!
    end

    def disable!
      adapter.disable!
    end

    def reset!
      ProtoPharm.stub_registry.reset!
    end

    def stub_registry
      @stub_registry ||= ProtoPharm::StubRegistry.new
    end

    def adapter
      @adapter ||= Adapter.new
    end

    def config
      @config ||= Configuration.new
    end
  end

  # Hook into GRPC::ClientStub
  # https://github.com/grpc/grpc/blob/bec3b5ada2c5e5d782dff0b7b5018df646b65cb0/src/ruby/lib/grpc/generic/service.rb#L150-L186
  GRPC::ClientStub.prepend GrpcStubAdapter::MockStub
end


# TODO: deprecate constant GrpcMock
