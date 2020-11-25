# frozen_string_literal: true

require 'active_support/core_ext/module/delegation'

require 'proto_pharm/request_pattern'
require 'proto_pharm/response'
require 'proto_pharm/response_sequence'
require 'proto_pharm/errors'

module ProtoPharm
  class RequestStub
    attr_reader :received_count, :request_pattern, :response_sequence

    delegate :path, to: :request_pattern, allow_nil: true

    # @param path [String] gRPC path like /${service_name}/${method_name}
    def initialize(path)
      @request_pattern = RequestPattern.new(path)
      @response_sequence = []
      @received_count = 0
    end

    def with(request = nil, &block)
      @request_pattern.with(request, &block)
      self
    end

    def to_return(*values)
      responses = [*values].flatten.map { |v| Response::Value.new(v) }
      @response_sequence << ProtoPharm::ResponsesSequence.new(responses)
      self
    end

    def to_raise(*exceptions)
      responses = [*exceptions].flatten.map { |e| Response::ExceptionValue.new(e) }
      @response_sequence << ProtoPharm::ResponsesSequence.new(responses)
      self
    end

    def response
      if @response_sequence.empty?
        raise ProtoPharm::NoResponseError, 'Must be set some values by using ProtoPharm::RequestStub#to_run'
      elsif @response_sequence.size == 1
        @response_sequence.first.next
      else
        if @response_sequence.first.end?
          @response_sequence.shift
        end

        @response_sequence.first.next
      end
    end

    def received!
      @received_count += 1
    end

    # @param path [String]
    # @param request [Object]
    # @return [Bool]
    def match?(path, request)
      @request_pattern.match?(path, request)
    end
  end
end
