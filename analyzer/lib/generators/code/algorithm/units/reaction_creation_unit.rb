module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The unit for combines statements of reaction creation
        class ReactionCreationUnit < MainCreationUnit
          include ReactionCreationMethods
          include ReactantAbstractType

        private

          # @return [String]
          def source_specie_name
            Specie::TARGET_SPECIE_NAME
          end
        end

      end
    end
  end
end
