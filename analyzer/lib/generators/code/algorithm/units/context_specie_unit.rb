module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Decorates unit for bulding specie dependent code on context
        class ContextSpecieUnit < ContextBaseUnit
          # @param [Array] _
          def initialize(*)
            super

            @_all_nodes_with_atoms, @_all_popular_atoms_nodes = nil

            @_is_over_used_atom, @_is_atom_many_usages_like_in_context = nil
            @_is_full_usages_match = nil
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_existence(&block)
            check_avail_atoms do
              check_that_context_specie_not_found(&block)
            end
          end

        protected

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def select_specie_definition(&block)
            if !many_similar_species? && (symmetric? || over_used_atom?)
              check_many_undefined_species(&block)
            elsif atom_many_usages_like_in_context?
              check_similar_undefined_species(&block)
            else
              unit.define_undefined_species(&block)
            end
          end

        private

          # @return [Array]
          def splitten_inner_units
            inner_units = unit.complete_inner_units
            if totally_splitten?(inner_units)
              inner_units
            else
              inner_units.flat_map(&:units)
            end
          end

          # @return [Array]
          def check_asymmetric_inner_units_procs
            units.select(&:asymmetric_related_atoms?).map do |inner_unit|
              -> &block { inner_unit.iterate_symmetries(&block) }
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_avail_atoms(&block)
            if any_defined?(species)
              check_symmetries do
                check_close_atoms(&block)
              end
            else
              unit.check_atoms_roles(atoms, &block)
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_close_atoms(&block)
            checking_nodes = context_nodes_with_undefined_atoms
            if checking_nodes.empty?
              block.call
            else
              pure_unit = pure_factory.unit(checking_nodes)
              pure_unit.define_undefined_atoms do
                pure_unit.check_different_atoms_roles(&block)
              end
            end
          end

          # @yield incorporating statement
          # @return [Expressions::OrCondition]
          def check_that_context_specie_not_found(&block)
            checks = unit.atom_with_specie_calls(:not_found, atoms, &:actual_anchor?)
            Expressions::OrCondition[checks, block.call]
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # @override
          def check_many_undefined_species(&block)
            if over_used_atom? || atom_many_usages_like_in_context?
              iterate_undefined_species(&block)
            else
              super(&block)
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_undefined_species(&block)
            unit.iterate_species_by_role do
              check_similar_defined_species do
                check_defined_context_parts do
                  check_symmetries(&block)
                end
              end
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_portioned_species(&block)
            checking_nodes = context_nodes_with_undefined_atoms
            if seems_different?(checking_nodes)
              unit.iterate_species_by_loop(&block)
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
          def check_similar_undefined_species(&block)
            if select_undefined(species).one?
              check_many_undefined_species(&block)
            else
              unit.iterate_portions_of_similar_species do
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
            species_pairs = similar_species_with(similar_nodes)
            if species_pairs.empty?
              block.call
            else
              vars_pairs = species_pairs.map(&method(:vars_for))
              Expressions::NotEqualsCondition[vars_pairs, block.call]
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_defined_context_parts(&block)
            nodes_pairs = common_atoms_nodes_pairs
            if nodes_pairs.empty?
              block.call
            else
              exprs_pairs = nodes_pairs_to_atoms_exprs(nodes_pairs)
              Expressions::NotEqualsCondition[exprs_pairs, block.call]
            end
          end

          # @return [Array]
          def context_nodes_with_undefined_atoms
            context.reachable_bone_nodes_with(select_defined(species))
          end

          # @return [Array]
          def original_different_defined_species_nodes
            different_defined_species_nodes.select do |node|
              nodes.any? do |n|
                n.uniq_specie.original == node.uniq_specie.original &&
                  n.sub_properties == node.sub_properties
              end
            end
          end

          # @param [Array] checking_nodes
          # @return [Array]
          def similar_species_with(checking_nodes)
            similar_species = checking_nodes.map(&:uniq_specie)
            similar_species.flat_map do |specie|
              species.select { |s| s.original == specie.original }.zip([specie].cycle)
            end
          end

          # Gets list of pairs of nodes which atoms are similar but belongs to
          # different species
          #
          # @return [Array]
          def common_atoms_nodes_pairs
            avail_species = all_nodes_with_atoms.map(&:uniq_specie).uniq
            defined_species = select_defined(avail_species)
            context.similar_atoms_nodes_pairs(defined_species).reject do |ns|
              ns.any? { |node| nodes.include?(node) }
            end
          end

          # @param [Array] atoms_pairs
          # @return [Array]
          def nodes_pairs_to_atoms_exprs(nodes_pairs)
            nodes_pairs.map { |ns| ns.map(&method(:atom_var_or_specie_call)) }
          end

          # Gets nodes which uses the atoms like inner unit, but contains defined
          # specie which is not same as any specie of inner unit
          #
          # @return [Array]
          def different_defined_species_nodes
            other_nodes = all_nodes_with_atoms - nodes
            if other_nodes.empty?
              []
            else
              other_nodes.select do |node|
                other_specie = node.uniq_specie
                !species.include?(other_specie) && dict.var_of(other_specie)
              end
            end
          end

          # @return [Array]
          def all_nodes_with_atoms
            @_all_nodes_with_atoms ||= context.atoms_nodes(atoms)
          end

          # @return [Array]
          def all_popular_atoms_nodes
            @_all_popular_atoms_nodes ||=
              all_nodes_with_atoms.select(&:used_many_times?)
          end

          # @return [Integer]
          def count_possible_atom_usages
            sum = all_popular_atoms_nodes.map(&:usages_num).reduce(:+)
            num = all_popular_atoms_nodes.size
            sum % num == 0 ? (sum / num) : sum
          end

          # @return [Boolean]
          def full_usages_match?
            return @_is_full_usages_match unless @_is_full_usages_match.nil?
            coincident_nodes = nodes.select(&:coincide?)
            comparing_nodes = coincident_nodes.empty? ? nodes : coincident_nodes
            @_is_full_usages_match =
              (count_possible_atom_usages == comparing_nodes.size)
          end

          # @return [Boolean]
          def atom_used_many_times?
            atoms.one? &&
              nodes.any?(&all_popular_atoms_nodes.public_method(:include?))
          end

          # @return [Boolean]
          def over_used_atom?
            return @_is_over_used_atom unless @_is_over_used_atom.nil?
            @_is_over_used_atom = atom_used_many_times? && !full_usages_match?
          end

          # @return [Boolean]
          def many_similar_species?
            atom_many_usages_like_in_context? &&
              !species.one? && species.map(&:original).uniq.one?
          end

          # @return [Boolean]
          def atom_many_usages_like_in_context?
            unless @_is_atom_many_usages_like_in_context.nil?
              return @_is_atom_many_usages_like_in_context
            end

            @_is_atom_many_usages_like_in_context =
              if atom_used_many_times?
                context_prop = all_popular_atoms_nodes.first.properties
                parent_props = all_popular_atoms_nodes.map(&:sub_properties)
                parent_props *= count_possible_atom_usages unless totally_popular?
                parent_props.reduce(:safe_plus) == context_prop
              else
                false
              end
          end

          # @return [Boolean]
          def totally_popular?
            lists_are_identical?(nodes, all_popular_atoms_nodes)
          end

          # @param [Array] inner_units
          # @return [Boolean]
          def totally_splitten?(inner_units)
            inner_units.empty? || inner_units != [unit] ||
              !atom_many_usages_like_in_context? || totally_popular?
          end

          # @param [Array] checking_nodes
          # @return [Boolean]
          def same_specie_in?(checking_nodes)
            if checking_nodes.any?(&:splittable?)
              false
            else
              checking_species = checking_nodes.map(&:uniq_specie).uniq
              checking_species.one? && !checking_species.all?(&:none?)
            end
          end

          # @param [Nodes::SpecieNode] a
          # @param [Nodes::SpecieNode] b
          # @return [Boolean]
          def checkable_neighbour_species?(a, b)
            [a, b].map(&:uniq_specie).reject(&:none?).size > 1
          end
        end

      end
    end
  end
end
