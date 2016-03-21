module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code from many nodes
        class ManyUnits < BaseUnit
          include Modules::ListsComparer

          # @param [Expressions::VarsDictionary] dict
          # @param [Array] units
          def initialize(dict, units)
            super(dict, units.flat_map(&:nodes))
            @units = units
          end

          # All different anchor atoms should have names
          def define!
            if atoms.one?
              anchor = atoms.first
              dict.make_atom_s(anchor, name: Code::Specie::ANCHOR_ATOM_NAME)
            else
              raise 'Incorrect number of entry atoms'
            end
          end

          # @return [Array]
          def filled_inner_units
            selected_units = @units.flat_map(&:filled_inner_units)
            nodes_lists = selected_units.map { |us| us.flat_map(&:nodes) }
            singular_same?(nodes_lists) ? [self] : selected_units
          end

        private

          # @param [Array] nodes_lists
          # @return [Boolean]
          def singular_same?(nodes_lists)
            same_units?(nodes_lists) && same_atom_in?(nodes_lists) &&
              same_props_in?(nodes_lists)
          end

          # @param [Array] nodes_lists
          # @return [Boolean]
          def same_units?(nodes_lists)
            lists_are_identical?(*nodes_lists, &:==)
          end

          # @param [Array] nodes_lists
          # @return [Boolean]
          def same_atom_in?(nodes_lists)
            nodes_lists.flat_map(&:atom).uniq.one?
          end

          # @param [Array] nodes_lists
          # @return [Boolean]
          def same_props_in?(nodes_lists)
            props_lists = nodes_lists.map { |ns| ns.map(&:properties) }
            lists_are_identical?(*props_lists, &:==)
          end
        end

      end
    end
  end
end
