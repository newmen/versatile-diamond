module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        module ReactantAbstractType
          # @return [Expressions::Core::ObjectType]
          def abstract_type
            Expressions::ReactantSpecieType[].freeze
          end
        end

      end
    end
  end
end
