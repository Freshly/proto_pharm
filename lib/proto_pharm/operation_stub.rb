# frozen_string_literal: true

module ProtoPharm
  class OperationStub
    attr_reader :response, :metadata, :trailing_metadata, :deadline
    alias_method :execute, :response

    # @param metadata [Hash] Any metadata passed into the GRPC request
    # @param deadline [Time] The deadline set on the GRPC request
    # @yieldreturn [*] The stubbed value or error expected to be returned from the request
    def initialize(response:, metadata: nil, deadline: nil)
      @response = response
      @metadata = metadata
      @deadline = deadline

      # TODO: support stubbing
      @trailing_metadata = {}
    end

    # TODO: support stubbing
    def cancelled?
      false
    end
  end
end
