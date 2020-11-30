# frozen_string_literal: true

require "active_support/core_ext/module"
require "grpc"

require_relative "proto_pharm/version"
require_relative "proto_pharm/configuration"

require_relative "proto_pharm/stub_components/failure_response"
require_relative "proto_pharm/stub_components/service_resolution"

require_relative "proto_pharm/adapter"
require_relative "proto_pharm/grpc_stub_adapter"
require_relative "proto_pharm/grpc_stub_adapter/mock_stub"

require_relative "proto_pharm/stub_registry"
require_relative "proto_pharm/api"

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

GrpcMock = ActiveSupport::Deprecation::DeprecatedConstantProxy.new("GrpcMock", "ProtoPharm")
