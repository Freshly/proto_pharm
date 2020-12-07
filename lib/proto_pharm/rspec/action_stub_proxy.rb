# frozen_string_literal: true

module ProtoPharm
  module RSpec
    class ActionStubProxy
      attr_reader :rpc_action, :expectations

      def initialize(rpc_action)
        @rpc_action = rpc_action
        @expectations = []
      end

      # Proxies ActionStub#with
      def with(*args, **kwargs)
        expectations << Expectation.new(:with, args, kwargs)

        self
      end

      # Proxies ActionStub#to_return
      def and_return(*args, **kwargs)
        expectations << Expectation.new(:to_return, args, kwargs)

        self
      end

      # Proxies ActionStub#to_raise
      def and_raise(*args, **kwargs)
        expectations << Expectation.new(:to_raise, args, kwargs)

        self
      end

      # Proxies ActionStub#to_fail_with
      def and_fail_with(*args, **kwargs)
        expectations << Expectation.new(:to_fail_with, args, kwargs)

        self
      end

      def and_fail
        expectations << Expectation.new(:to_fail, [], {})

        self
      end

      class Expectation
        attr_reader :method, :args, :kwargs

        def initialize(method, args, kwargs)
          @method = method
          @args = args
          @kwargs = kwargs
        end
      end
    end
  end
end
