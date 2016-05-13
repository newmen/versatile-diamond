module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm::Units

        # Decorates unit for bulding code on context
        # @abstract
        class ContextBaseUnit < GenerableUnit
          include Modules::ProcsReducer
          include Modules::ListsComparer
          extend Forwardable

          attr_reader :unit # must be protected

          # @param [Expressions::VarsDictionary] dict
          # @param [BasePureUnitsFactory] pure_factory
          # @param [BaseContextProvider] context
          # @param [BasePureUnit] unit
          def initialize(dict, pure_factory, context, unit)
            super(dict)
            @pure_factory = pure_factory
            @context = context
            @unit = unit
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_avail_species(&block)
            inner_units = splitten_inner_units
            if inner_units.empty?
              check_complete_unit(&block)
            else
              call_procs(check_avail_species_procs(inner_units), &block)
            end
          end

          # @param [ContextBaseUnit] nbr
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_relations_with(nbr, &block)
            if unit.neighbour?(nbr.unit)
              check_neighbour_relations(nbr) do
                check_avail_species_in(nbr, &block)
              end
            else
              check_avail_species_in(nbr, &block)
            end
          end

          # Must be protected
          # @return [Boolean] gets false if close nodes are not symmetric and true
          #   in the case when neighbour nodes are not similar
          def asymmetric_related_atoms?
            area_nodes = context.symmetric_close_nodes(species)
            close_nodes = area_nodes.reject(&check_own_node_proc)
            close_nodes.one? ||
              !(close_nodes.empty? || context.symmetric_relations?(close_nodes))
          end

          def to_s
            inspect
          end

          def inspect
            sis = species.map(&:inspect)
            pops = nodes.uniq(&:atom).map(&:properties).map(&:inspect)
            kns = nodes.map do |n|
              ds = n.uniq_specie.spec
              ch = ds.instance_variable_get(:@child) || ds
              ch.spec.keyname(n.atom)
            end
            kwps = kns.zip(pops).map { |kp| kp.join(':') }
            "∞(#{sis.join(' ')}) | (#{kwps.join(' ')})∞"
          end

        protected

          def_delegator :unit, :nodes

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
            if one_symmetric_specie?
              unit.iterate_specie_symmetries(&block)
            elsif asymmetric_related_atoms?
              unit.iterate_for_loop_symmetries(&block)
            else
              raise 'Incorrect unit configuration'
            end
          end

          # @return [Array]
          def neighbour_nodes_pairs
            nodes.combination(2).select do |a, b|
              relation = context.relation_between(a, b)
              relation && relation.exist?
            end
          end

        private

          def_delegators :unit, :species, :anchored_species, :atoms, :symmetric_atoms
          attr_reader :pure_factory, :context

          # @return [ContextBaseUnit]
          def context_unit(inner_unit)
            self.class.new(dict, pure_factory, context, inner_unit)
          end

          # @return [Array]
          def units
            unit.units.map(&method(:context_unit))
          end

          # @return [Proc]
          def check_own_node_proc
            nodes.public_method(:include?)
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

          # @param [BasePureUnit] inner_unit
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
            inner_units.map do |inner_unit|
              -> &block { check_splitten_unit(inner_unit, &block) }
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_many_undefined_species(&block)
            unit.define_undefined_species do
              check_symmetries(&block)
            end
          end

          # All atoms of unit species already defined there...
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_new_atoms(&block)
            reachable_nodes = context.reachable_bone_nodes_after(nodes)
            if !reachable_nodes.empty? && atoms_comparison_required?(reachable_nodes)
              check_not_existed_previous_atoms(reachable_nodes) do
                check_existed_previous_atoms(reachable_nodes, &block)
              end
            else
              block.call
            end
          end

          # @param [ContextBaseUnit] nbr
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_avail_species_in(nbr, &block)
            defined_ancns = defined_same_neighbour_nodes(nbr)
            nbr.check_avail_species do
              check_eq_previous_atoms(defined_ancns, except_own: false) do
                nbr.check_private_relations(&block)
              end
            end
          end

          # @param [ContextBaseUnit] nbr
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_neighbour_relations(nbr, &block)
            if all_defined?(nbr.atoms) && relations_between(self, nbr).all?(&:bond?)
              check_bonds_to_defined_neighbour(nbr, &block)
            else
              iterate_relations(nbr, &block)
            end
          end

          # @param [ContextBaseUnit] nbr
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

          # @param [ContextBaseUnit] nbr
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

          # @param [ContextBaseUnit] nbr
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

          # @param [ContextBaseUnit] nbr
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
                check_bond_between(pairs + nbr.neighbour_nodes_pairs, &block)
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
            relating_nodes = context.existed_relations_to(checking_nodes)
            check_eq_previous_atoms(relating_nodes, &block)
          end

          # @param [Array] checking_nodes
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_not_existed_previous_atoms(checking_nodes, &block)
            relating_nodes = context.not_existed_relations_to(checking_nodes)
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
            sncns = context.symmetric_close_nodes(species)
            defined_sncns = sncns.select { |node| dict.var_of(node.uniq_specie) }
            defined_sncns.any?(&check_own_node_proc) ? defined_sncns : []
          end

          # @param [ContextBaseUnit] nbr
          # @return [Array] the list of nodes which will be available again after
          #   neighbour unit species check
          def defined_same_neighbour_nodes(nbr)
            if context.key?(nbr.nodes)
              defined_next_neighbour_nodes(nbr)
            else
              sncns = context.symmetric_close_nodes(nbr.species)
              undefined_sncns = sncns.reject { |node| dict.var_of(node.uniq_specie) }
              undefined_sncns.select(&check_own_node_proc)
            end
          end

          # @param [ContextBaseUnit] nbr
          # @return [Array]
          def defined_next_neighbour_nodes(nbr)
            if context.cutten_bone_relations_from?(nodes, nbr.nodes)
              []
            else
              nbr.nodes.select { |n| species.include?(n.uniq_specie) }
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
            context.private_relations_with(nodes).map do |pair|
              pair.map(&method(:atom_var_or_specie_call))
            end
          end

          # @param [Nodes::BaseNode] node
          # @return [Expressions::Core::Expression]
          def atom_var_or_specie_call(node)
            dict.var_of(node.atom) || atom_from_specie_call(node)
          end

          # @param [Nodes::BaseNode] node
          # @return [Expressions::Core::Expression]
          def atom_from_specie_call(node)
            dict.var_of(node.uniq_specie).atom_value(node.atom)
          end

          # Gets all existed relations over backbone graph of context
          # The first element of each item is pair of [from, to] nodes
          #
          # @param [ContextBaseUnit] nbr
          # @return [Array]
          def nodes_with_existed_relations(nbr)
            ns_with_rs = zip_nodes_of(self, nbr).zip(relations_between(self, nbr))
            nodes_lists = ns_with_rs.select { |_, r| r.exist? }.map(&:first)
            nodes_lists.reject(&method(:same_specie_in?))
          end

          # @param [ContextBaseUnit] a
          # @param [ContextBaseUnit] b
          # @return [Array]
          def relations_between(a, b)
            zip_nodes_of(a, b).map { |ns| context.relation_between(*ns) }
          end

          # @param [Array] zipping_units
          # @return [Array]
          def zip_nodes_of(*zipping_units)
            as, bs = zipping_units.map(&:unit).map(&:nodes)
            as.smart_zip(bs)
          end

          # @return [Array]
          def possible_symmetric_nodes
            # already should be checked that unit is symmetric
            symmetric_nodes = nodes.select(&:symmetric_atoms?)
            if symmetric_nodes.empty?
              nodes.reject do |node|
                context.symmetric_close_nodes([node.uniq_specie]).empty?
              end
            else
              symmetric_nodes
            end
          end

          # @return [Boolean]
          def symmetric?
            unit.fully_symmetric? || unit.partially_symmetric? ||
              asymmetric_related_atoms?
          end

          # @return [Boolean]
          def one_symmetric_specie?
            possible_symmetric_nodes.map(&:uniq_specie).uniq.one?
          end

          # @param [Array] ca_nodes
          # @return [Boolean]
          def seems_different?(ca_nodes)
            ca_species = ca_nodes.map(&:uniq_specie).uniq
            return true unless lists_are_identical?(species, ca_species, &:==)
            return true unless ca_nodes.map { |n| n.uniq_specie.original }.uniq.one?

            groups = ca_nodes.groups(&:uniq_specie)
            !groups.one? &&
              !lists_are_identical?(*groups) do |*ns|
                ns.map(&:sub_properties).uniq.one?
              end
          end

          # @param [Array] checking_nodes
          # @return [Boolean]
          def atoms_comparison_required?(checking_nodes)
            symmetric? || context.related_from_other_defined?(checking_nodes)
          end

          # @param [Array] pair
          # @return [Boolean]
          def checkable_bond_between?(*pair)
            relation = context.relation_between(*pair)
            relation.bond? &&
              pair.all? { |n| context.just_existed_bone_relations?(n) } &&
              (relation != Concepts::Bond.amorph || checkable_neighbour_species?(*pair))
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
