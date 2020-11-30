# frozen_string_literal: true

require_relative "service_resolution/resolver"

module ProtoPharm
  module StubComponents
    module ServiceResolution
      private

      def resolve_service(service)
        Resolver.resolve(service)
      end
    end
  end
end
