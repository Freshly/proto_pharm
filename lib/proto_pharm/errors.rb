# frozen_string_literal: true

module ProtoPharm
  class Error < StandardError; end

  class NetConnectNotAllowedError < Error
    def initialize(sigunature)
      super("Real gRPC connections are disabled. #{sigunature} is requested")
    end
  end

  class NoResponseError < Error
    def initialize(msg)
      super("There is no response: #{msg}")
    end
  end

  class InvalidProtoType < Error; end
  class RpcNotFoundError < Error; end
  class RpcNotStubbedError < Error; end
end
