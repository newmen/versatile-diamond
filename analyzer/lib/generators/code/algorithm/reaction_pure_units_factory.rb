module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for reaction find algorithm
        class ReactionPureUnitsFactory < BasePureUnitsFactory
        private

          # @param [Arra] args
          # @return [Units::MonoReactionUnit]
          def make_mono_unit(*args)
            Units::MonoReactionUnit.new(*args)
          end

          # @param [Arra] args
          # @return [Units::ManyReactionUnits]
          def make_many_units(*args)
            Units::ManyReactionUnits.new(*args)
          end
        end

      end
    end
  end
end
