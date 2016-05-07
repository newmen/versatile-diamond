module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for specie find algorithm
        class SpeciePureUnitsFactory < BaseUnitsFactory
        private

          # @param [Arra] args
          # @return [Units::MonoSpecieUnit]
          def make_mono_unit(*args)
            Units::MonoSpecieUnit.new(*args)
          end

          # @param [Arra] args
          # @return [Units::ManySpecieUnits]
          def make_many_units(*args)
            Units::ManySpecieUnits.new(*args)
          end
        end

      end
    end
  end
end
