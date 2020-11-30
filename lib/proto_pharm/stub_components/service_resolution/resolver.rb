  # frozen_string_literal: true

  module ProtoPharm
    module StubComponents
      module ServiceResolution
      module Resolver
        class InvalidGRPCServiceError < StandardError; end

        class << self
          def resolve(service)
            raise InvalidGRPCServiceError, "Not a valid gRPC service module: #{service.inspect}" unless service.respond_to?(:const_defined?)

            service.const_defined?(:Service) ? service::Service : service
          end
        end

        # We'll need this later
        # attr_reader :service

        # def initialize(service)
        #   @service = service
        # end
      end
    end
  end
end
