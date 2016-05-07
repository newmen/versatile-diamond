module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for specie find algorithm
        class SpecieUnitsFactoryWithContext < SpeciePureUnitsFactory

          # @param [Units::Expressions::VarsDictionary] dict
          def initialize(dict, context)
            super(dict)
            @context = context
          end

          # @param [Array] nodes for which the unit will be maked
          # @return [Units::BaseContextUnit]
          def unit(nodes)
            Units::BaseContextUnit.new(dict, @context, super)
          end
        end

      end
    end
  end
end
