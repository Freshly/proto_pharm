# frozen_string_literal: true

module ProtoPharm
  class Adapter
    delegate :enable!, :disable!, :enabled?, to: :adapter

    private

    def adapter
      @adapter ||= GrpcStubAdapter.new
    end
  end
end
