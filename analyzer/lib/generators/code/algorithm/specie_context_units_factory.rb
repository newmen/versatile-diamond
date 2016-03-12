module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for specie find algorithm
        class SpecieContextUnitsFactory < SpeciePureUnitsFactory

          # @param [Units::NameRemember] namer
          def initialize(namer, context)
            super(namer)
            @context = context
          end

          # @param [Array] nodes for which the unit will be maked
          # @return [Units::ContextUnit]
          def unit(nodes)
            Units::ContextUnit.new(*default_args, @context, super)
          end
        end

      end
    end
  end
end
