# frozen_string_literal: true

require "active_support/core_ext/module"
require "active_support/core_ext/object/blank"

require "directive"
require "grpc"

require_relative "proto_pharm/version"
require_relative "proto_pharm/configuration"

require_relative "proto_pharm/introspection"
require_relative "proto_pharm/stub_components/failure_response"

require_relative "proto_pharm/adapter"
require_relative "proto_pharm/grpc_stub_adapter"
require_relative "proto_pharm/grpc_stub_adapter/mock_stub"

require_relative "proto_pharm/metadata_serializers/base"
require_relative "proto_pharm/metadata_serializers/gruf"
require_relative "proto_pharm/request_stub"
require_relative "proto_pharm/action_stub"
require_relative "proto_pharm/matchers/request_including_matcher"
require_relative "proto_pharm/stub_registry"
require_relative "proto_pharm/api"

module ProtoPharm
  extend ProtoPharm::Api

  include Directive::ConfigDelegation
  delegates_to_configuration

  class << self
    delegate :enable!, :disable!, :enabled?, to: :adapter

    def reset!
      ProtoPharm.stub_registry.reset!
    end

    def stub_registry
      @stub_registry ||= ProtoPharm::StubRegistry.new
    end

    def adapter
      @adapter ||= Adapter.new
    end
  end

  # Hook into GRPC::ClientStub
  # https://github.com/grpc/grpc/blob/bec3b5ada2c5e5d782dff0b7b5018df646b65cb0/src/ruby/lib/grpc/generic/service.rb#L150-L186
  GRPC::ClientStub.prepend GrpcStubAdapter::MockStub
end

GrpcMock = ActiveSupport::Deprecation::DeprecatedConstantProxy.new("GrpcMock", "ProtoPharm")
