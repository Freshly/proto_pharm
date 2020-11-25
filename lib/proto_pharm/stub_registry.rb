# frozen_string_literal: true

module ProtoPharm
  class StubRegistry
    attr_reader :request_stubs

    def initialize
      @request_stubs = {}
    end

    def reset!
      @request_stubs = {}
    end

    # @param stub [ProtoPharm::RequestStub]
    def register_request_stub(stub)
      request_stubs[stub.path] ||= []
      request_stubs[stub.path].unshift(stub)
      stub
    end

    # @param path [String]
    # @param request [Object]
    # @return [*] Response stubbed for the given request, if a matching stub can be found
    def response_for_request(path, request)
      request_stubs[path].find { |stub| stub.match?(path, request) }&.response
    end
  end
end
