# frozen_string_literal: true

require_relative "errors"
require_relative "operation_stub"

module ProtoPharm
  class GrpcStubAdapter
    delegate :enable!, :disable!, to: :class

    class << self
      def disable!
        @enabled = false
      end

      def enable!
        @enabled = true
      end

      def enabled?
        @enabled
      end
    end
  end
end
