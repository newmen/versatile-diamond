module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for check laterals find algorithm
        class CheckLateralsPureUnitsFactory < LateralChunksPureUnitsFactory
        private

          # @param [Array] args
          # @return [Units::MonoSidepieceUnit]
          def make_mono_target_unit(*args)
            Units::MonoSidepieceUnit.new(*args)
          end

          # @param [Array] args
          # @return [Units::MonoReactionUnit]
          def make_mono_side_unit(*args)
            Units::MonoReactionUnit.new(*args)
          end

          # @param [Array] args
          # @return [Units::ManySidepieceUnits]
          def make_many_target_units(*args)
            Units::ManySidepieceUnits.new(*args)
          end

          # @param [Array] args
          # @return [Units::ManyReactionUnits]
          def make_many_side_units(*args)
            Units::ManyReactionUnits.new(*args)
          end
        end

      end
    end
  end
end
