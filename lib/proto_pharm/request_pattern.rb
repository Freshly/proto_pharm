# frozen_string_literal: true

module ProtoPharm
  class RequestPattern
    attr_reader :path, :request, :block

    # @param path [String]
    def initialize(path)
      @path = path
      @block = nil
      @request = nil
    end

    def with(request = nil, &block)
      if request.nil? && !block_given?
        raise ArgumentError, "#with method invoked with no arguments. Either options request or block must be specified."
      end

      @request = request
      @block = block
    end

    def match?(match_path, match_request)
      path == match_path &&
        (request.nil? || request == match_request) &&
        (block.nil? || block.call(match_path))
    end
  end
end
