module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Decorates unit for bulding code on context
        class ContextUnit < GenerableUnit

          # @param [NameRemember] namer
          # @param [BaseContext] context
          # @param [BaseUnit] unit
          def initialize(namer, context, unit)
            super(namer)
            @context = context
            @unit = unit
          end

          # @yield incorporating statement
          # @return [Statement]
          def check_avail_atoms(&block)
            if any_defined?(species)
              check_symmetries { check_required_atoms(&block) }
            else
              check_atom_roles(&block)
            end
          end

        private

          def_delegators :unit, :species, :atoms

          # Checks that atoms have specific types
          # @yield incorporating statement
          # @return [Statement]
          def check_atom_roles(&block)
            @context.var_of(atoms).check_roles_in(species, block.call)
          end

          # @yield incorporating statement
          # @return [Statement]
          def check_symmetries(&block)
            symmetric? ? iterate_symmetries(&block) : block.call
          end

          # @yield incorporating statement
          # @return [Statement]
          def iterate_symmetries(&block)
            if species.one? || atoms.one?
              iterate_specie_symmetries(&block)
            else
              iterate_for_loop_symmetries(&block)
            end
          end

          # @yield incorporating statement
          # @return [Statement]
          def iterate_specie_symmetries(&block)
            defined_species = select_defined(species)
            if defined_species.one?
              iterate_redefined_specie_symmetries!(defined_species.first, &block)
            elsif defined_species.empty?
              raise 'Symmetric specie is not defined'
            else
              raise 'Too many defined symmetric species'
            end
          end

          # @param [Instances::SpecieInstance] specie
          # @yield incorporating statement
          # @return [Statement]
          def iterate_redefined_specie_symmetries!(specie, &block)
            var = @context.var_of(specie)
            inner_var, func_call = var.iterate_symmetries(block.call)
            @context.retain_var!(specie, inner_var)
            func_call
          end

          # @yield incorporating statement
          # @return [Statement]
          def iterate_for_loop_symmetries(&block)
          end

          # @return [Boolean]
          def symmetric?
            mono_symmetric? || asymmetric_related_atoms? || partially_symmetric?
          end

          # @return [Boolean]
          def mono_symmetric?
            atoms.one? && @context.symmetries_of(atoms.first).size > species.size
          end

          # @return [Boolean] gets false if close nodes are not symmetric and true
          #   in the case when neighbour nodes are not similar
          def asymmetric_related_atoms?
            nodes = symmetric_close_nodes(species)
            !(nodes.empty? || @context.symmetric_relations?(nodes))
          end

          # @return [Boolean]
          def partially_symmetric?
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
