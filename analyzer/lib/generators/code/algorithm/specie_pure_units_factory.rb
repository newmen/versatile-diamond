module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for specie find algorithm
        class SpeciePureUnitsFactory < BaseUnitsFactory
        private

          # @param [Arra] args
          # @return [Units::PureMonoUnit]
          def make_mono_unit(*args)
            Units::PureMonoUnit.new(*args)
          end

          # @param [Arra] args
          # @return [Units::PureManyUnit]
          def make_mono_unit(*args)
            Units::PureManyUnit.new(*args)
          end
        end

      end
    end
  end
end
