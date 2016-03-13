module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Decorates unit for bulding code on context
        class ContextUnit < GenerableUnit
          include Modules::ProcsReducer
          extend Forwardable

          # @param [Expressions::VarsDictionary] dict
          # @param [BaseContext] context
          # @param [BaseUnit] unit
          def initialize(dict, context, unit)
            super(dict)
            @context = context
            @unit = unit

            @_all_popular_atoms_nodes = nil
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: specie specific
          def check_existence(&block)
            check_avail_atoms do
              check_that_context_specie_not_found(&block)
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_avail_species(&block)
            combine_avail_species_checks do
              check_new_atoms(&block)
            end
          end

        protected

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: specie specific
          def select_specie_definition(&block)
            if symmetric? || over_used_atom?
            elsif atom_usages_like_in_context?
            else
            end
          end

        private

          def_delegators :@unit, :species, :atoms

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: just specie
          def check_avail_atoms(&block)
            if any_defined?(species)
              check_symmetries { check_close_atoms(&block) }
            else
              @unit.check_atoms_roles(atoms, &block)
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: just specie
          def check_that_context_specie_not_found(&block)
            dict.var_of(atoms).check_context(species, block.call)
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_symmetries(&block)
            symmetric? ? @unit.iterate_symmetries(&block) : block.call
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def combine_avail_species_checks(&block)
            call_procs(avail_species_check_procs, &block)
          end

          # @return [Array]
          def avail_species_check_procs
            @unit.filled_inner_units.map do |inner_unit|
              -> &block { check_undefined_species_of(inner_unit, &block) }
            end
          end

          # @param [BaseUnit] inner_unit
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_undefined_species_of(inner_unit, &block)
            if inner_unit.checkable?
              context_unit = self.class.new(dict, @context, inner_unit)
              context_unit.select_specie_definition(&block)
            else
              block.call
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_new_atoms(&block)
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: specie specific
          def check_close_atoms(&block)
            nodes = @context.reachable_nodes_with(select_defined(species))
            if nodes.empty?
              block.call
            else
              @unit.define_undefined_atoms(nodes.map(&:atom)) +
                @unit.check_different_atoms_roles(nodes, &block)
            end
          end

          # @return [Integer]
          def count_possible_atom_usages
            all_popular_atoms_nodes.map(&:usages_num).reduce(:+)
          end

          # @return [Array]
          def all_popular_atoms_nodes
            @_all_popular_atoms_nodes ||=
              @context.all_nodes_with(atoms).select(&:used_many_times?)
          end

          # @return [Boolean]
          def atom_used_many_times?
            atoms.one? && !all_popular_atoms_nodes.empty?
          end

          # @return [Boolean]
          def over_used_atom?
            atom_used_many_times? && count_possible_atom_usages != species.size
          end

          # @return [Boolean]
          # TODO: just specie
          def atom_usages_like_in_context?
            context_prop = all_popular_atoms_nodes.first.properties
            parent_props =
              all_popular_atoms_nodes.map { |n| n.uniq_specie.properties_of(n.atom) }

            parent_props.reduce(:accurate_plus) == context_prop
          end

          # @return [Boolean]
          def symmetric?
            mono_self_symmetric? || partially_self_symmetric? ||
              asymmetric_related_atoms?
          end

          # @return [Boolean] gets false if close nodes are not symmetric and true
          #   in the case when neighbour nodes are not similar
          def asymmetric_related_atoms?
            nodes = @context.symmetric_close_nodes(species)
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
