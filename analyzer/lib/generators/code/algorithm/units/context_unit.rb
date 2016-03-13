module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Decorates unit for bulding code on context
        class ContextUnit < GenerableUnit
          extend Forwardable

          # @param [Expressions::VarsDictionary] dict
          # @param [BaseContext] context
          # @param [BaseUnit] unit
          def initialize(dict, context, unit)
            super(dict)
            @context = context
            @unit = unit
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: just specie
          def check_avail_atoms(&block)
            if any_defined?(species)
              check_symmetries { check_required_atoms(&block) }
            else
              @unit.check_atom_roles(&block)
            end
          end

        private

          def_delegators :@unit, :species, :atoms

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_symmetries(&block)
            symmetric? ? @unit.iterate_symmetries(&block) : block.call
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_required_atoms(&block)
          end

          # @return [Boolean]
          def symmetric?
            mono_self_symmetric? || partially_self_symmetric? ||
              asymmetric_related_atoms?
          end

          # @return [Boolean] gets false if close nodes are not symmetric and true
          #   in the case when neighbour nodes are not similar
          def asymmetric_related_atoms?
            nodes = symmetric_close_nodes(species)
            !(nodes.empty? || @context.symmetric_relations?(nodes))
          end

          # @return [Boolean]
          def mono_self_symmetric?
            atoms.one? && @context.symmetries_of(atoms.first).size > species.size
          end

          # @return [Boolean]
          def partially_self_symmetric?
            !atoms.one? && subset_symmetric_atoms?
          end

          # @return [Boolean]
          def subset_symmetric_atoms?
            method = @context.public_method(:symmetries_of)
            symmetric_atoms = atoms.flat_map(&method).to_set
            !symmetric_atoms.empty? && symmetric_atoms < atoms.to_set &&
              @context.symmetric_relations?(@unit.nodes_with(symmetric_atoms))
          end
        end

      end
    end
  end
end
