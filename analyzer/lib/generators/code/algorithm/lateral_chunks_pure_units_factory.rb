module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for lateral reaction find algorithm
        # @abstract
        class LateralChunksPureUnitsFactory < BasePureUnitsFactory
        private

          # @param [Units::Expressions::VarsDictionary] dict
          # @param [Nodes::BaseNode] node
          # @return [Units::MonoPureUnit]
          def make_mono_unit(dict, node)
            if node.side?
              make_mono_side_unit(dict, node)
            else
              make_mono_target_unit(dict, node)
            end
          end

          # @param [Units::Expressions::VarsDictionary] dict
          # @param [Array] units
          # @return [Units::ManyPureUnits]
          def make_many_units(dict, units)
            unless units.flat_map(&:nodes).any?(&:side?)
              make_many_target_units(dict, units)
            else
              make_many_side_units(dict, units)
            end
          end
        end

      end
    end
  end
end
