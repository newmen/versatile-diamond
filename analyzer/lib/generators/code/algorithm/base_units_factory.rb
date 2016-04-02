module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates units for find algorithm
        # @abstract
        class BaseUnitsFactory
          # Initializes find algorithm units factory
          # @param [Units::Expressions::VarsDictionary] dict
          def initialize(dict)
            @dict = dict
          end

          # Makes unit that correspond to passed nodes
          # @param [Array] nodes for which the unit will be maked
          # @return [Units::BaseUnit]
          def unit(nodes)
            nodes.one? ? mono_unit(nodes.first) : many_units(nodes)
          end

        private

          attr_reader :dict

          # Creates checker unit from one node
          # @param [Nodes::BaseNode] node by which the checker unit will be created
          # @return [Units::BaseUnit]
          def mono_unit(node)
            node.scope? ? many_units(node.split) : make_mono_unit(dict, node)
          end

          # Creates many units by list of nodes
          # @param [Array] nodes by which the many units will be created
          # @return [Units::ManyUnits]
          def many_units(nodes)
            make_many_units(dict, nodes.map(&method(:mono_unit)))
          end
        end

      end
    end
  end
end
