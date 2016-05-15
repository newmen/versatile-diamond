module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for targets of look around find algorithm
        class LateralTargetPureUnitsFactory < BasePureUnitsFactory
        private

          # @param [Arra] args
          # @return [Units::MonoLateralTargetUnit]
          def make_mono_unit(*args)
            Units::MonoLateralTargetUnit.new(*args)
          end

          # @param [Arra] args
          # @return [Units::ManyLateralTargetUnits]
          def make_many_units(*args)
            Units::ManyLateralTargetUnits.new(*args)
          end
        end

      end
    end
  end
end
