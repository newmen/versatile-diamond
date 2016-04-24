module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm::Units

        # Decorates unit for bulding code on context
        class ContextUnit < GenerableUnit
          include Modules::ProcsReducer
          include Modules::ListsComparer
          extend Forwardable

          attr_reader :unit # must be protected

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
            inner_units = unit.filled_inner_units
            if inner_units.empty?
              check_complete_unit(&block)
            else
              call_procs(check_avail_species_procs(inner_units)) do
                check_complete_unit(&block)
              end
            end
          end

          # @param [ContextUnit] nbr
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_relations_with(nbr, &block)
            if unit.neighbour?(nbr)
              check_neighbour_relations(nbr) do
                check_avail_species_in(nbr, &block)
              end
            else
              check_avail_species_in(nbr, &block)
            end
          end

          # @return [Boolean] gets false if close nodes are not symmetric and true
          #   in the case when neighbour nodes are not similar
          # TODO: must be protected
          def asymmetric_related_atoms?
            area_nodes = @context.symmetric_close_nodes(species)
            close_nodes = area_nodes.reject(&check_own_node_proc)
            close_nodes.one? ||
              !(close_nodes.empty? || @context.symmetric_relations?(close_nodes))
          end

          def to_s
            inspect
          end

          def inspect
            sis = species.map(&:inspect)
            pops = nodes.uniq(&:atom).map(&:properties).map(&:inspect)
            "∞(#{sis.join(' ')})-(#{pops.join(' ')})∞"
          end

        protected

          def_delegator :unit, :nodes

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: specie specific
          def select_specie_definition(&block)
            if symmetric? || over_used_atom?
              check_many_undefined_species(&block)
            elsif atom_many_usages_like_in_context?
              check_similar_undefined_species(&block)
            else
              unit.define_undefined_species(&block)
            end
          end

          # @yield incorporating statement
          # @return [Expressions::NotEqualsCondition]
          def check_private_relations(&block)
            pairs = zip_private_related_exprs
            if pairs.empty?
              block.call
            else
              Expressions::NotEqualsCondition[pairs, block.call]
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_symmetries(&block)
            if possible_symmetric_nodes.one?
              unit.iterate_specie_symmetries(&block)
            elsif asymmetric_related_atoms?
              unit.iterate_for_loop_symmetries(&block)
            else
              raise 'Incorrect unit configuration'
            end
          end

        private

          def_delegators :unit, :species, :anchored_species, :atoms, :symmetric_atoms

          # @return [ContextUnit]
          def context_unit(inner_unit)
            self.class.new(dict, @context, inner_unit)
          end

          # @return [Array]
          def units
            unit.units.map(&method(:context_unit))
          end

          # @return [Array]
          def possible_symmetric_nodes
            # already should be checked that unit is symmetric
            symmetric_nodes = nodes.select(&:symmetric_atoms?)
            symmetric_nodes.empty? ? nodes : symmetric_nodes
          end

          # @return [Proc]
          def check_own_node_proc
            nodes.public_method(:include?)
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
              unit.check_atoms_roles(atoms, &block)
            end
          end

          # @yield incorporating statement
          # @return [Expressions::OrCondition]
          # TODO: just specie
          def check_that_context_specie_not_found(&block)
            checks = unit.atom_with_specie_calls(:not_found, atoms)
            Expressions::OrCondition[checks, block.call]
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_symmetries(&block)
            if symmetric?
              defined_ancns = defined_self_next_same_nodes
              iterate_symmetries do
                check_eq_previous_atoms(defined_ancns, except_own: false, &block)
              end
            else
              block.call
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_complete_unit(&block)
            check_close_atoms do
              check_new_atoms(&block)
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_splitten_unit(inner_unit, &block)
            check_undefined_species_of(inner_unit) do
              check_complete_unit(&block)
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

          # @param [Array] inner_units
          # @return [Array]
          def check_avail_species_procs(inner_units)
            complete_units = inner_units.flat_map(&method(:split_on_compliance))
            complete_units.map do |inner_unit|
              -> &block { check_splitten_unit(inner_unit, &block) }
            end
          end

          # @param [BaseUnit] inner_unit
          # @return [Array]
          def split_on_compliance(inner_unit)
            complete_unit?(inner_unit) ? [inner_unit] : inner_unit.units
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: specie specific
          def check_many_undefined_species(&block)
            if over_used_atom? || atom_many_usages_like_in_context?
              iterate_undefined_species(&block)
            else
              unit.define_undefined_species do
                check_symmetries(&block)
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
          # TODO: just specie (do not move it to #unit.define_undefined_species)
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
          def iterate_undefined_species(&block)
            unit.iterate_species_by_role do
              check_similar_defined_species do
                check_symmetries do
                  check_defined_context_parts(&block)
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

          # All atoms of unit species already defined there...
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_new_atoms(&block)
            reached_nodes = @context.species_nodes(species)
            if !reached_nodes.empty? && atoms_comparison_required?(reached_nodes)
              check_not_existed_previous_atoms(reached_nodes) do
                check_existed_previous_atoms(reached_nodes, &block)
              end
            else
              block.call
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: specie specific
          def check_close_atoms(&block)
            checking_nodes = context_nodes_with_undefined_atoms
            if checking_nodes.empty?
              block.call
            else
              pure_unit = SpeciePureUnitsFactory.new(dict).unit(checking_nodes)
              pure_unit.define_undefined_atoms do
                pure_unit.check_different_atoms_roles(&block)
              end
            end
          end

          # @param [ContextUnit] nbr
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_avail_species_in(nbr, &block)
            defined_ancns = defined_neighbour_self_same_nodes(nbr)
            nbr.check_avail_species do
              check_eq_previous_atoms(defined_ancns, except_own: false) do
                nbr.check_private_relations(&block)
              end
            end
          end

          # @param [ContextUnit] nbr
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_neighbour_relations(nbr, &block)
            if all_defined?(nbr.atoms) && relations_between(self, nbr).all?(&:bond?)
              check_bonds_to_defined_neighbour(nbr, &block)
            else
              iterate_relations(nbr, &block)
            end
          end

          # @param [ContextUnit] nbr
          # @yield incorporating statement
          # @return [Expressions::AndCondition]
          def check_bonds_to_defined_neighbour(nbr, &block)
            pairs = zip_nodes_of(self, nbr).map { |pair| pair.map(&:atom) }
            check_bonds_condition(pairs, &block)
          end

          # @param [Array] pairs
          # @yield incorporating statement
          # @return [Expressions::AndCondition]
          def check_bonds_condition(pairs, &block)
            exprs = pairs.map(&method(:vars_for)).map { |a, b| a.has_bond_with(b) }
            Expressions::AndCondition[exprs, block.call]
          end

          # @param [ContextUnit] nbr
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_relations(nbr, &block)
            crystal_rels_proc = -> &prc { iterate_crystal_relations(nbr, &prc) }
            unit.check_amorph_bonds_if_have(nbr.unit, crystal_rels_proc) do
              check_private_relations do
                check_existed_relations(nbr, &block)
              end
            end
          end

          # @param [ContextUnit] nbr
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_crystal_relations(nbr, &block)
            predefn_vars = dict.defined_vars # get before make inner nbr atoms var
            self_var = dict.var_of(atoms)
            nbr_var = dict.make_atom_s(nbr.atoms, name: 'neighbour')
            lattice =
              Expressions::Core::ObjectType[nodes.first.lattice_class.class_name]
            relations = relations_between(self, nbr)
            are_same_relations = relations.uniq(&:exist?).one?

            sns, nns = [self, nbr].map(&:unit).map(&:nodes).map do |ns|
              anchored = ns.select(&:anchor?)
              anchored.empty? ? ns : anchored
            end
            ssz, nsz = [sns, nns].map(&:size)
            args = [predefn_vars, nbr_var, lattice, relations.first.params, block.call]

            if ssz < nsz && are_same_relations
              self_var.all_crystal_nbrs(*args)
            elsif ssz > nsz && are_same_relations
              self_var.nbr_from(*args)
            elsif ssz == nsz
              self_var.iterate_over_lattice(*args)
            else
              raise ArgumentError, 'Incorrect relations configuration between nodes'
            end
          end

          # @param [ContextUnit] nbr
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_existed_relations(nbr, &block)
            pairs = nodes_with_existed_relations(nbr)
            near_atoms = pairs.map(&:last).map(&:atom).uniq
            new_atoms = near_atoms.reject(&dict.public_method(:prev_var_of)).uniq
            if new_atoms.empty?
              block.call
            else
              nbr.unit.check_atoms_roles(new_atoms) do
                check_bond_between(pairs + neighbour_nodes_pairs(nbr), &block)
              end
            end
          end

          # @param [Array] pairs
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_bond_between(pairs, &block)
            checkable_pairs =
              pairs.uniq.select { |pair| checkable_bond_between?(*pair) }

            if checkable_pairs.empty?
              block.call
            else
              atoms_pairs = checkable_pairs.map { |pair| pair.map(&:atom) }
              check_bonds_condition(atoms_pairs, &block)
            end
          end

          # @param [Array] checking_nodes
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_existed_previous_atoms(checking_nodes, &block)
            relating_nodes = @context.existed_relations_to(checking_nodes)
            check_eq_previous_atoms(relating_nodes, &block)
          end

          # @param [Array] checking_nodes
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_not_existed_previous_atoms(checking_nodes, &block)
            relating_nodes = @context.not_existed_relations_to(checking_nodes)
            check_not_eq_previous_atoms(relating_nodes, &block)
          end

          # @param [Array] checking_nodes
          # @param [Hash] kwargs set ignore own previous atoms or not
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_eq_previous_atoms(checking_nodes, **kwargs, &block)
            cond_expr_class = Expressions::EqualsCondition
            check_previous_atoms(cond_expr_class, checking_nodes, **kwargs, &block)
          end

          # @param [Array] checking_nodes
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_not_eq_previous_atoms(checking_nodes, &block)
            cond_expr_class = Expressions::NotEqualsCondition
            check_previous_atoms(cond_expr_class, checking_nodes, &block)
          end

          # @param [Class] cond_expr_class
          # @param [Array] checking_nodes
          # @param [Hash] kwargs set ignore own previous atoms or not
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_previous_atoms(cond_expr_class, checking_nodes, **kwargs, &block)
            vars_pairs = zip_vars_with_previous(checking_nodes, **kwargs)
            if vars_pairs.empty?
              block.call
            else
              cond_expr_class[vars_pairs, block.call]
            end
          end

          # @return [Array] the list of nodes which will be available again after
          #   neighbour unit species check
          def defined_self_next_same_nodes
            sncns = @context.symmetric_close_nodes(species)
            defined_sncns = sncns.select { |node| dict.var_of(node.uniq_specie) }
            defined_sncns.any?(&check_own_node_proc) ? defined_sncns : []
          end

          # @param [ContextUnit] nbr
          # @return [Array] the list of nodes which will be available again after
          #   neighbour unit species check
          def defined_neighbour_self_same_nodes(nbr)
            if @context.key?(nbr.nodes)
              []
            else
              sncns = @context.symmetric_close_nodes(nbr.species)
              undefined_sncns = sncns.reject { |node| dict.var_of(node.uniq_specie) }
              undefined_sncns.select(&check_own_node_proc)
            end
          end

          # @param [Array] zipping_nodes
          # @param [Hash] kwargs set ignore own previous atoms or not
          # @return [Array]
          def zip_vars_with_previous(zipping_nodes, **kwargs)
            old_nodes = zipping_nodes.select { |n| old_atom_var?(n, **kwargs) }
            old_nodes.map do |node|
              [
                dict.var_of(node.atom),
                dict.prev_var_of(node.atom) || atom_from_specie_call(node)
              ]
            end
          end

          # @return [Array]
          def zip_private_related_exprs
            @context.private_relations_with(nodes).map do |pair|
              pair.map(&method(:atom_var_or_specie_call))
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
          def similar_nodes_pairs
            original_different_defined_species_nodes.flat_map do |node|
              nodes_pairs_with(node.uniq_specie)
            end
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
            dict.var_of(node.atom) || atom_from_specie_call(node)
          end

          # @param [Nodes::BaseNode] node
          # @return [Expressions::Core::Expression]
          # TODO: move to MonoUnit?
          def atom_from_specie_call(node)
            dict.var_of(node.uniq_specie).atom_value(node.atom)
          end

          # @param [Array] atoms_pairs
          # @return [Array]
          def nodes_pairs_to_atoms_exprs(nodes_pairs)
            nodes_pairs.map { |ns| ns.map(&method(:atom_var_or_specie_call)) }
          end

          # @param [Array] atoms_pairs
          # @param [Instance::SpecieInstance] self_specie
          # @param [Instance::SpecieInstance] other_specie
          # @return [Array]
          def atoms_pairs_to_nodes(atoms_pairs, self_specie, other_specie)
            self_nodes = @context.species_nodes([self_specie])
            other_nodes = @context.species_nodes([other_specie])
            atoms_pairs.each_with_object([]) do |(self_atom, other_atom), acc|
              self_node = self_nodes.find { |n| n.atom == self_atom }
              other_node = other_nodes.find { |n| n.atom == other_atom }
              acc << [self_node, other_node] if self_node && other_node
            end
          end

          # @param [ContextUnit] nbr
          # @return [Array]
          def neighbour_nodes_pairs(nbr)
            nbr.nodes.combination(2).select do |a, b|
              relation = @context.relation_between(a, b)
              relation && relation.exist?
            end
          end

          # Gets all existed relations over backbone graph of context
          # The first element of each item is pair of [from, to] nodes
          #
          # @param [ContextUnit] nbr
          # @return [Array]
          def nodes_with_existed_relations(nbr)
            ns_with_rs = zip_nodes_of(self, nbr).zip(relations_between(self, nbr))
            nodes_lists = ns_with_rs.select { |_, r| r.exist? }.map(&:first)
            nodes_lists.reject(&method(:same_specie_in?))
          end

          # @param [ContextUnit] a
          # @param [ContextUnit] b
          # @return [Array]
          def relations_between(a, b)
            zip_nodes_of(a, b).map { |ns| @context.relation_between(*ns) }
          end

          # @param [Array] zipping_units
          # @return [Array]
          def zip_nodes_of(*zipping_units)
            as, bs = zipping_units.map(&:unit).map(&:nodes)
            as.smart_zip(bs)
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
            sum = all_popular_atoms_nodes.map(&:usages_num).reduce(:+)
            num = all_popular_atoms_nodes.size
            sum % num == 0 ? (sum / num) : sum
          end

          # @return [Boolean]
          def full_usages_match?
            coincident_nodes = nodes.select(&:coincide?)
            comparing_nodes = coincident_nodes.empty? ? nodes : coincident_nodes
            count_possible_atom_usages != comparing_nodes.size
          end

          # @return [Boolean]
          def atom_used_many_times?
            atoms.one? &&
              nodes.any?(&all_popular_atoms_nodes.public_method(:include?))
          end

          # @return [Boolean]
          def over_used_atom?
            @_is_over_used_atom ||= atom_used_many_times? && full_usages_match?
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
            unit.fully_symmetric? || partially_symmetric? || asymmetric_related_atoms?
          end

          # @return [Boolean]
          def partially_symmetric?
            @_is_partially_symmetric ||= unit.partially_symmetric? &&
              @context.symmetric_relations?(unit.nodes_with_atoms(symmetric_atoms))
          end

          # @param [Array] ca_nodes
          # @return [Boolean]
          def seems_different?(ca_nodes)
            other_atoms = ca_nodes.map(&:atom).uniq
            return false if lists_are_identical?(atoms, other_atoms, &:==)

            oa_num = other_atoms.size
            return false if oa_num >= species.size || oa_num % species.size == 0

            sub_props = ca_nodes.map(&:sub_properties).uniq
            return false unless oa_num % sub_props.size == 0

            groups = ca_nodes.groups(&:uniq_specie)
            return false unless groups.map(&:size).uniq.one?

            group_subs = groups.first.map(&:sub_properties).uniq
            !(lists_are_identical?(sub_props, group_subs, &:==) &&
              lists_are_identical?(species, ca_nodes.map(&:uniq_specie).uniq, &:==))
          end

          # @param [Array] checking_nodes
          # @return [Boolean]
          def atoms_comparison_required?(checking_nodes)
            symmetric? || @context.related_from_other_defined?(checking_nodes)
          end

          # @param [Array] checking_nodes
          # @return [Boolean]
          # TODO: specie specific
          def same_specie_in?(checking_nodes)
            checking_species = checking_nodes.map(&:uniq_specie).uniq
            checking_species.size < 2 && !checking_species.all?(&:none?)
          end

          # @param [Array] pair
          # @return [Boolean]
          def checkable_bond_between?(*pair)
            relation = @context.relation_between(*pair)
            relation.bond? && (relation != Concepts::Bond.amorph ||
              checkable_neighbour_species?(*pair))
          end

          # @param [Nodes::BaseNode] a
          # @param [Nodes::BaseNode] b
          # @return [Boolean]
          # TODO: specie specific
          def checkable_neighbour_species?(a, b)
            [a, b].map(&:uniq_specie).reject(&:none?).size > 1
          end

          # @param [BaseUnit] inner_unit
          # @return [Boolean]
          def complete_unit?(inner_unit)
            @context.bone_referred?(inner_unit.nodes) ||
              inner_unit.atoms.size > 1 ||
              coincident_nodes_of?(inner_unit)
          end

          # @param [BaseUnit] inner_unit
          # @return [Boolean]
          def coincident_nodes_of?(inner_unit)
            values = inner_unit.nodes.map(&:coincide?)
            !values.any? || values.all?
          end

          # @param [Nodes::BaseNode] node
          # @option [Boolean] :except_own
          # @return [Boolean]
          def old_atom_var?(node, except_own: true)
            dict.prev_var_of(node.atom) ||
              (!(except_own && atoms.include?(node.atom)) &&
                dict.var_of(node.uniq_specie) && dict.var_of(node.atom))
          end
        end

      end
    end
  end
end
