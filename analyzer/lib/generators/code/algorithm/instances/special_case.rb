module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # Represents the special case of unique parent specie instance
        # @abstract
        class SpecialCase
          include SpecieInstancesOrder
          extend Forwardable

          attr_reader :original
          def_delegator :original, :spec

          # Initialize special case
          # @param [Specie] original which is original and will be remembered
          def initialize(original)
            @original = original
          end
        end

      end
    end
  end
end
