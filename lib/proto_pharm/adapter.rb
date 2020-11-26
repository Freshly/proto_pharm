# frozen_string_literal: true

module ProtoPharm
  class Adapter
    delegate :enable!, :disable!, to: :adapter

    private

    def adapter
      @adapter ||= GrpcStubAdapter.new
    end
  end
end
