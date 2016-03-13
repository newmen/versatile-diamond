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
          # @return [Units::ManyUnit]
          def make_mono_unit(*args)
            Units::ManyUnit.new(*args)
          end
        end

      end
    end
  end
end
