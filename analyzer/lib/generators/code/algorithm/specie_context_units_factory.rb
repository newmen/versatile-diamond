module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for specie find algorithm
        class SpecieContextUnitsFactory < BaseContextUnitsFactory
          # @param [Array] nodes for which the unit will be maked
          # @return [Units::ContextSpecieUnit]
          def unit(nodes)
            Units::ContextSpecieUnit.new(dict, pure_factory, context, pure_unit(nodes))
          end

          # @param [Specie] specie
          # @return [Units::SpecieCreationUnit]
          def creator(specie)
            Units::SpecieCreationUnit.new(dict, context, specie)
          end
        end

      end
    end
  end
end
