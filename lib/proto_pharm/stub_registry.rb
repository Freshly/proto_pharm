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
    # @return [ProtoPharm::RequestStub] RequestStub matching the given path/request, if found
    def find_request_matching(path, request)
      request_stubs[path]&.find { |stub| stub.match?(path, request) }
    end
  end
end
