# frozen_string_literal: true

module ProtoPharm
  module MetadataSerializers
    module Base
      class << self
        def serialize(**metadata)
          metadata.fetch(:metadata, {})
        end
      end
    end
  end
end
