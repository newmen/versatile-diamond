module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for specie find algorithm
        class SpeciePureUnitsFactory < BasePureUnitsFactory
        private

          # @param [Array] args
          # @return [Units::MonoSpecieUnit]
          def make_mono_unit(*args)
            Units::MonoSpecieUnit.new(*args)
          end

          # @param [Array] args
          # @return [Units::ManySpecieUnits]
          def make_many_units(*args)
            Units::ManySpecieUnits.new(*args)
          end

          # Creates checker unit from one node
          # @param [Nodes::BaseNode] node by which the checker unit will be created
          # @return [Units::BasePureUnit]
          # @override
          def mono_unit(node)
            node.splittable? ? many_units(node.split) : super
          end
        end

      end
    end
  end
end
