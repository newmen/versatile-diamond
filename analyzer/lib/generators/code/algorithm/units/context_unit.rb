module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Decorates unit for bulding code on context
        class ContextUnit < GenerableUnit
          include Modules::ProcsReducer
          include Modules::ListsComparer
          extend Forwardable

          # @param [Expressions::VarsDictionary] dict
          # @param [BaseContext] context
          # @param [BaseUnit] unit
          def initialize(dict, context, unit)
            super(dict)
            @context = context
            @unit = unit

            @_all_nodes_with_atoms, @_all_popular_atoms_nodes = nil

            @_is_partially_symmetric = nil
            @_is_over_used_atom, @_is_atom_many_usages_like_in_context = nil
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
              check_many_undefined_species(&block)
            elsif atom_many_usages_like_in_context?
              check_similar_undefined_species(&block)
            else
              @unit.define_undefined_species(&block)
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_symmetries(&block)
            if species.one? || atoms.one?
              @unit.iterate_specie_symmetries(&block)
            elsif asymmetric_related_atoms?
              @unit.iterate_for_loop_symmetries(&block)
            else
              raise 'Incorrect unit configuration'
            end
          end

          # @return [Boolean] gets false if close nodes are not symmetric and true
          #   in the case when neighbour nodes are not similar
          def asymmetric_related_atoms?
            nodes = @context.symmetric_close_nodes(species)
            nodes.one? || !(nodes.empty? || @context.symmetric_relations?(nodes))
          end

        private

          def_delegators :@unit, :species, :atoms, :symmetric_atoms

          # @return [ContextUnit]
          def context_unit(inner_unit)
            self.class.new(dict, @context, inner_unit)
          end

          # @return [Array]
          def units
            @unit.units.map(&method(:context_unit))
          end

          # @return [Array]
          def check_asymmetric_inner_units_procs
            units.select(&:asymmetric_related_atoms?).map do |inner_unit|
              -> &block { inner_unit.iterate_symmetries(&block) }
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: just specie
          def check_avail_atoms(&block)
            if any_defined?(species)
              check_symmetries do
                check_close_atoms(&block)
              end
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
            symmetric? ? iterate_symmetries(&block) : block.call
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
              context_unit(inner_unit).select_specie_definition(&block)
            else
              block.call
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: specie specific
          def check_many_undefined_species(&block)
            if over_used_atom? || atom_many_usages_like_in_context?
              iterate_undefined_species(&block)
            else
              @unit.define_undefined_species do
                check_symmetries(&block)
              end
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_portioned_species
            nodes = context_nodes_with_undefined_atoms
            if seems_different?(nodes)
              @unit.iterate_species_by_loop(&block)
            else
              block.call
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_each_asymmetric_inner_unit(&block)
            call_procs(check_asymmetric_inner_units_procs, &block)
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: just specie (do not move it to #@unit.define_undefined_species)
          def check_similar_undefined_species(&block)
            if select_undefined(species).one?
              check_many_undefined_species(&block)
            else
              @unit.iterate_portions_of_similar_species do
                iterate_portioned_species do
                  check_each_asymmetric_inner_unit(&block)
                end
              end
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_similar_defined_species(&block)
            similar_nodes = original_different_defined_species_nodes
            if similar_nodes.empty?
              block.call
            else
              species_pairs = similar_species_with(similar_nodes)
              vars_pairs = species_pairs.map(&method(:vars_for))
              Expressions::NotEqualsCondition[vars_pairs, block.call]
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_undefined_species(&block)
            @unit.iterate_species_by_role do
              check_similar_defined_species do
                check_defined_context_parts do
                  check_symmetries(&block)
                end
              end
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_defined_context_parts(&block)
            nodes_pairs = similar_nodes_pairs
            if nodes_pairs.empty?
              block.call
            else
              exprs_pairs = nodes_pairs_to_atoms_exprs(nodes_pairs)
              Expressions::NotEqualsCondition[exprs_pairs, block.call]
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_new_atoms(&block)
            check_close_atoms do
              nodes = @context.reached_nodes_with(species)
              if !nodes.empty? && atoms_comparison_required?(nodes)
                check_not_existed_previos_atoms(nodes) do
                  check_existed_previos_atoms(nodes, &block)
                end
              else
                block.call
              end
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: specie specific
          def check_close_atoms(&block)
            nodes = context_nodes_with_undefined_atoms
            if nodes.empty?
              block.call
            else
              pure_unit = SpeciePureUnitsFactory.new(dict).unit(nodes)
              pure_unit.define_undefined_atoms do
                pure_unit.check_different_atoms_roles(&block)
              end
            end
          end

          # @param [Array] nodes
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_existed_previos_atoms(nodes, &block)
            same_nodes = @context.existed_relations_to(nodes)
            check_previos_atoms(Expressions::EqualsCondition, same_nodes, &block)
          end

          # @param [Array] nodes
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_not_existed_previos_atoms(nodes, &block)
            not_nodes = @context.not_existed_relations_to(nodes)
            check_previos_atoms(Expressions::NotEqualsCondition, not_nodes, &block)
          end

          # @param [Class] cond_expr_class
          # @param [Array] nodes
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_previos_atoms(cond_expr_class, nodes, &block)
            vars_pairs = zip_vars_with_previos(nodes.map(&:atom))
            if vars_pairs.empty?
              block.call
            else
              cond_expr_class[vars_pairs, block.call]
            end
          end

          # @param [Array] atoms
          # @return [Array]
          def zip_vars_with_previos(atoms)
            atoms.select(&dict.public_method(:prev_var_of)).map do |atom|
              [dict.var_of(atom), dict.prev_var_of(atom)]
            end
          end

          # @param [Array] nodes
          # @return [Array]
          def similar_species_with(nodes)
            similar_species = similar_nodes.map(&:uniq_specie)
            species_pairs = species.flat_map do |specie|
              scmps = similar_species.select { |s| s.original == specie.original }
              scmp.zip([specie].cycle)
            end
          end

          # Gets list of pairs of nodes which atoms are similar but belongs to
          # different species
          #
          # @return [Array]
          def similar_nodes_pairs
            totaly_different_defined_species_nodes.flat_map do |node|
              nodes_pairs_with(node.unit_specie)
            end
          end

          # @return [Array]
          def totaly_different_defined_species_nodes
            filter_original_different_defined_species_nodes(:reject)
          end

          # @return [Array]
          def original_different_defined_species_nodes
            filter_original_different_defined_species_nodes(:select)
          end

          # @param [Symbol] method_name
          # @return [Array]
          def filter_original_different_defined_species_nodes(method_name)
            originals = species.map(&:original).uniq
            different_defined_species_nodes.public_send(method_name) do |node|
              origianls.include?(node.uniq_specie.original)
            end
          end

          # Gets nodes which uses the atoms like inner unit, but contains defined
          # specie which is not same as any specie of inner unit
          #
          # @return [Array]
          def different_defined_species_nodes
            (all_nodes_with_atoms - @unit.nodes).select do |node|
              other_specie = node.unit_specie
              !species.include?(other_specie) && dict.var_of(other_specie)
            end
          end

          # @param [Instance::SpecieInstance] other_specie
          # @return [Array]
          def nodes_pairs_with(other_specie)
            species.flat_map do |self_specie|
              all_atoms_pairs = self_specie.common_atoms_with(other_specie)
              different_atoms_pairs = all_atoms_pairs.reject { |as| as.uniq.one? }
              if different_atoms_pairs.empty?
                []
              else
                atoms_pairs_to_nodes(different_atoms_pairs, self_specie, other_specie)
              end
            end
          end

          # @param [Nodes::BaseNode] node
          # @return [Expressions::Core::Expression]
          # TODO: move to MonoUnit?
          def atom_var_or_specie_call(node)
            dict.var_of(node.atom) ||
              dict.var_of(node.uniq_specie).atom_value(node.atom)
          end

          # @param [Array] atoms_pairs
          # @return [Array]
          def nodes_pairs_to_atoms_exprs(nodes_pairs)
            nodes_pairs.map { |nodes| nodes.map(&method(:atom_var_or_specie_call)) }
          end

          # @param [Array] atoms_pairs
          # @param [Instance::SpecieInstance] self_specie
          # @param [Instance::SpecieInstance] other_specie
          # @return [Array]
          def atoms_pairs_to_nodes(atoms_pairs, self_specie, other_specie)
            self_nodes = @context.specie_nodes([self_specie])
            other_nodes = @context.specie_nodes([other_specie])
            atoms_pairs.each_with_object([]) do |(self_atom, other_atom), acc|
              self_node = self_nodes.find { |n| n.atom == self_atom }
              other_node = other_nodes.find { |n| n.atom == other_atom }
              acc << [self_node, other_node] if self_node && other_node
            end
          end

          # @return [Array]
          def context_nodes_with_undefined_atoms
            @context.reachable_nodes_with(select_defined(species))
          end

          # @return [Array]
          def all_nodes_with_atoms
            @_all_nodes_with_atoms ||= @context.atoms_nodes(atoms)
          end

          # @return [Array]
          def all_popular_atoms_nodes
            @_all_popular_atoms_nodes ||=
              all_nodes_with_atoms.select(&:used_many_times?)
          end

          # @return [Integer]
          def count_possible_atom_usages
            all_popular_atoms_nodes.map(&:usages_num).reduce(:+)
          end

          # @return [Boolean]
          def atom_used_many_times?
            atoms.one? && !all_popular_atoms_nodes.empty?
          end

          # @return [Boolean]
          def over_used_atom?
            @_is_over_used_atom ||=
              atom_used_many_times? && count_possible_atom_usages != species.size
          end

          # @return [Boolean]
          # TODO: just specie
          def atom_many_usages_like_in_context?
            @_is_atom_many_usages_like_in_context ||=
              if atom_used_many_times?
                context_prop = all_popular_atoms_nodes.first.properties
                parent_props = all_popular_atoms_nodes.map(&:sub_properties)
                parent_props.reduce(:safe_plus) == context_prop
              else
                false
              end
          end

          # @return [Boolean]
          def symmetric?
            @unit.fully_symmetric? || partially_symmetric? || asymmetric_related_atoms?
          end

          # @return [Boolean]
          def partially_symmetric?
            @_is_partially_symmetric ||= @unit.partially_symmetric? &&
              @context.symmetric_relations?(@unit.nodes_with_atoms(symmetric_atoms))
          end

          # @param [Array] nodes
          # @return [Boolean]
          def seems_different?(nodes)
            other_atoms = nodes.map(&:atom).uniq
            !(lists_are_identical?(atoms, other_atoms, &:==) ||
              (other_atoms.size == species.size &&
                nodes.map(&:sub_properties).uniq.one? &&
                lists_are_identical?(species, nodes.map(&:unit_specie).uniq, &:==)))
          end

          # @param [Array] nodes
          # @return [Boolean]
          def atoms_comparison_required?(nodes)
            symmetric? || @context.related_from_other_defined(nodes)
          end
        end

      end
    end
  end
end
