module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides base logic for building algorithms
        # @abstract
        class BaseAlgorithmBuilder
          # Generates find algorithm cpp code
          # @return [String] the string with cpp code of find algorithm
          def build
            complete_algorithm.shifted_code
          end
        end

      end
    end
  end
end
