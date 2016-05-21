module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for look around find algorithm
        class LookAroundPureUnitsFactory < BasePureUnitsFactory
        private

          # @param [Units::Expressions::VarsDictionary] dict
          # @param [Nodes::BaseNode] node
          # @return [Units::MonoPureUnit]
          def make_mono_unit(dict, node)
            if node.side?
              Units::MonoSidepieceUnit.new(dict, node)
            else
              Units::MonoLateralTargetUnit.new(dict, node)
            end
          end

          # @param [Units::Expressions::VarsDictionary] dict
          # @param [Array] units
          # @return [Units::ManyPureUnits]
          def make_many_units(dict, units)
            unless units.flat_map(&:nodes).any?(&:side?)
              Units::ManyLateralTargetUnits.new(dict, units)
            else
              Units::ManySidepieceUnits.new(dict, units)
            end
          end
        end

      end
    end
  end
end
