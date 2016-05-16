module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for reaction find algorithm
        class LookAroundPureUnitsFactory < BasePureUnitsFactory
        private

          # @param [Units::Expressions::VarsDictionary] dict
          # @param [Nodes::BaseNode] node
          # @return [Units::MonoPureUnit]
          def make_mono_unit(dict, node)
            if node.side?
              Units::MonoReactionUnit.new(dict, node)
            else
              Units::MonoLateralTargetUnit.new(dict, node)
            end
          end

          # @param [Units::Expressions::VarsDictionary] dict
          # @param [Array] nodes
          # @return [Units::ManyPureUnits]
          def make_many_units(dict, nodes)
            unless nodes.any?(&:side?)
              Units::ManyLateralTargetUnits.new(dict, nodes)
            else
              Units::ManyReactionUnits.new(dict, nodes)
            end
          end
        end

      end
    end
  end
end
