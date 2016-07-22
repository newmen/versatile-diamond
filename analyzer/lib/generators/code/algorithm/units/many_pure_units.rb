module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code from many nodes
        # @abstract
        class ManyPureUnits < BasePureUnit
          include Modules::ListsComparer

          # @param [Expressions::VarsDictionary] dict
          # @param [Array] units
          def initialize(dict, units)
            super(dict, units.flat_map(&:nodes))
            @units = units
          end

          # @return [Array]
          def units
            @units.flat_map(&:units)
          end

          # @return [Array]
          def filled_inner_units
            selected_units = @units.flat_map(&:filled_inner_units)
            singular_same?(selected_units.map(&:nodes)) ? [self] : selected_units
          end

        private

          # @param [Array] nodes_lists
          # @return [Boolean]
          def singular_same?(nodes_lists)
            selected_nodes = nodes_lists.flatten
            same_nodes?(selected_nodes) && same_atom_in?(selected_nodes) &&
              same_props_in?(nodes_lists)
          end

          # @param [Array] selected_nodes
          # @return [Boolean]
          def same_nodes?(selected_nodes)
            lists_are_identical?(selected_nodes, nodes)
          end

          # @param [Array] selected_nodes
          # @return [Boolean]
          def same_atom_in?(selected_nodes)
            selected_nodes.map(&:atom).uniq.one?
          end

          # @param [Array] nodes_lists
          # @return [Boolean]
          def same_props_in?(nodes_lists)
            lists_are_identical?(*nodes_lists.map { |ns| ns.map(&:properties) })
          end
        end

      end
    end
  end
end
