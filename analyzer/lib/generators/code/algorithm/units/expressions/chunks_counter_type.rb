module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Represents chunks counter type statement
        class ChunksCounterType < Core::ObjectType

          STD_NS_NAME = Core::ObjectType['std'].freeze
          CONTAINER_TYPE =
            Core::OpNs[STD_NS_NAME, Core::ObjectType['unordered_map']].freeze
          KEY_TYPE = Core::ScalarType['ushort'].freeze
          VALUE_TYPE = KEY_TYPE
          UMAP_ARGS = [KEY_TYPE, VALUE_TYPE].freeze

          class << self
            def []
              super(CONTAINER_TYPE.code, template_args: UMAP_ARGS)
            end
          end
        end

      end
    end
  end
end
