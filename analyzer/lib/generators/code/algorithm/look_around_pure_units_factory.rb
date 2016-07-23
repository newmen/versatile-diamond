module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for look around find algorithm
        class LookAroundPureUnitsFactory < LateralChunksPureUnitsFactory
        private

          # @param [Array] args
          # @return [Units::MonoLateralTargetUnit]
          def make_mono_target_unit(*args)
            Units::MonoLateralTargetUnit.new(*args)
          end

          # @param [Array] args
          # @return [Units::MonoSidepieceUnit]
          def make_mono_side_unit(*args)
            Units::MonoSidepieceUnit.new(*args)
          end

          # @param [Array] args
          # @return [Units::ManyLateralTargetUnits]
          def make_many_target_units(*args)
            Units::ManyLateralTargetUnits.new(*args)
          end

          # @param [Array] args
          # @return [Units::ManySidepieceUnits]
          def make_many_side_units(*args)
            Units::ManySidepieceUnits.new(*args)
          end
        end

      end
    end
  end
end
