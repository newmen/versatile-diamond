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

            @_all_nodes_with_atoms, @_all_popular_atoms_nodes = nil
            @_symmetric_atoms = nil
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
            elsif atom_usages_like_in_context?
              check_similar_undefined_species(&block)
            else
              @unit.define_undefined_species(&block)
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
            symmetric? ? iterate_symmetries(&block) : block.call
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
          # TODO: specie specific
          def check_many_undefined_species(&block)
            if over_used_atom? || atom_usages_like_in_context?
              iterate_undefined_species(&block)
            else
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: just specie (do not move it to #define_undefined_species)
          def check_similar_undefined_species(&block)
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
              pure_unit = SpeciePureUnitsFactory.new(dict).unit(nodes)
              pure_unit.define_undefined_atoms do
                pure_unit.check_different_atoms_roles(&block)
              end
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

          # @param [Array] pairs
          # @param [Instance::SpecieInstance] self_specie
          # @param [Instance::SpecieInstance] other_specie
          # @return [Array]
          def atoms_pairs_to_nodes(pairs, self_specie, other_specie)
            self_nodes = @context.specie_nodes(self_specie)
            other_nodes = @context.specie_nodes(other_specie)
            pairs.each_with_object([]) do |(self_atom, other_atom), acc|
              self_node = self_nodes.find { |n| n.atom == self_atom }
              other_node = other_nodes.find { |n| n.atom == other_atom }
              acc << [self_node, other_node] if self_node && other_node
            end
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
            atom_used_many_times? && count_possible_atom_usages != species.size
          end

          # @return [Boolean]
          # TODO: just specie
          def atom_usages_like_in_context?
            if atom_used_many_times?
              context_prop = all_popular_atoms_nodes.first.properties
              parent_props = all_popular_atoms_nodes.map(&:sub_properties)
              parent_props.reduce(:accurate_plus) == context_prop
            else
              false
            end
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
            !nodes.empty? && (nodes.one? || !@context.symmetric_relations?(nodes))
          end

          # @return [Boolean]
          def mono_self_symmetric?
            atoms.one? && symmetric_atoms.size > species.size
          end

          # @return [Boolean]
          def partially_self_symmetric?
            !atoms.one? && subset_symmetric_atoms?
          end

          # @return [Boolean]
          def subset_symmetric_atoms?
            !symmetric_atoms.empty? && symmetric_atoms < atoms.to_set &&
              @context.symmetric_relations?(@unit.nodes_with(symmetric_atoms))
          end

          # @return [Array]
          def symmetric_atoms
            @_symmetric_atoms ||= @unit.nodes.flat_map(&:symmetric_atoms).uniq
          end
        end

      end
    end
  end
end
