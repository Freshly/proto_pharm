# frozen_string_literal: true

module ProtoPharm
  class OperationStub
    attr_reader :response_proc, :metadata, :trailing_metadata, :deadline

    # @param metadata [Hash] Any metadata passed into the GRPC request
    # @param deadline [Time] The deadline set on the GRPC request
    # @yieldreturn [*] The stubbed value or error expected to be returned from the request
    def initialize(metadata: nil, deadline: nil, &response_proc)
      @response_proc = response_proc
      @metadata = metadata
      @deadline = deadline

      # TODO: support stubbing
      @trailing_metadata = {}
    end

    # Calls the block given upon instantiation and returns the result
    def response
      response_proc.call
    end
    alias_method :execute, :response

    # TODO: support stubbing
    def cancelled?
      false
    end
  end
end
