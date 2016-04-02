module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for specie find algorithm
        class SpeciePureUnitsFactory < BaseUnitsFactory
        private

          # @param [Arra] args
          # @return [Units::MonoUnit]
          def make_mono_unit(*args)
            Units::MonoUnit.new(*args)
          end

          # @param [Arra] args
          # @return [Units::ManyUnits]
          def make_many_units(*args)
            Units::ManyUnits.new(*args)
          end
        end

      end
    end
  end
end
