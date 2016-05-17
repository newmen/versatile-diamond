module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm::Units

        # The basic unit for each other
        # @abstract
        class BasePureUnit < GenerableUnit
          include Modules::OrderProvider

          attr_reader :nodes

          # @param [Expressions::VarsDictionary] dict
          # @param [Array] nodes
          def initialize(dict, nodes)
            super(dict)
            @nodes = nodes

            @_species, @_anchored_species, @_atoms, @_symmetric_atoms = nil
          end

          # @param [BasePureUnit] other
          # @return [Integer]
          def <=>(other)
            order(self, other, :nodes, :size) do
              order(self, other, :atoms, :size) do
                order(self, other, :species, :size, &comparing_core(other))
              end
            end
          end

          # @return [Array]
          def species
            @_species ||= uniq_from_nodes(:uniq_specie)
          end

          # @return [Array]
          def anchored_species
            @_anchored_species ||= nodes.select(&:anchor?).map(&:uniq_specie).uniq
          end

          # @return [Array]
          def atoms
            @_atoms ||= uniq_from_nodes(:atom)
          end

          # @return [Array]
          def symmetric_atoms
            @_symmetric_atoms ||= nodes.flat_map(&:symmetric_atoms).uniq
          end

          # @return [Array]
          def complete_inner_units
            filled_inner_units.flat_map(&method(:split_on_compliance)).sort
          end

          # @param [Symbol] method_name
          # @param [Array] calling_atoms
          # @yield [SpecieInstance, Atom] checks that atom belongs to specie
          # @return [Array]
          def atom_with_specie_calls(method_name, calling_atoms, &block)
            pack_with_species(calling_atoms, &block).map do |atom, specie|
              dict.var_of(atom).public_send(method_name, specie)
            end
          end

          # Checks that atoms have specific types
          # @param [Array] checking_atoms
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_atoms_roles(checking_atoms, &block)
            checks = atom_with_specie_calls(:role_in, checking_atoms, &:atom?)
            Expressions::AndCondition[checks, block.call]
          end

          # @param [BasePureUnit] nbr
          # @param [Proc] crystal_rels_proc
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_amorph_bonds_if_have(nbr, crystal_rels_proc, &block)
            lattices = (atoms + nbr.atoms).map(&:lattice)
            if lattices.all? && lattices.uniq.one?
              redefine_self_and_nbr_atoms_if_need(nbr) do
                crystal_rels_proc[&block]
              end
            elsif atoms.one? && nbr.atoms.one?
              iterate_amorph_bonds(nbr, &block)
            else
              raise ArgumentError, 'Cannot itearte relations between units'
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_specie_symmetries(&block)
            defined_species = defined_symmetric_species
            if defined_species.one?
              iterate_defined_specie_symmetries(defined_species.first, &block)
            elsif defined_species.empty?
              raise 'Symmetric specie was not defined'
            else
              raise 'Too many defined symmetric species'
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_for_loop_symmetries(&block)
            define_undefined_atoms do
              redefine_atoms_as_array do
                dict.var_of(atoms).each(block.call)
              end
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def define_undefined_atoms(&block)
            if all_defined?(atoms)
              block.call
            else
              make_undefined_atoms_from_defined_species.define_var + block.call
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def define_undefined_species(&block)
            if all_defined?(anchored_species)
              block.call
            else
              check_undefined_species(&block)
            end
          end

          # @return [Boolean]
          def fully_symmetric?
            atoms.one? && symmetric_atoms.size > species.size
          end

          # @return [Boolean]
          def partially_symmetric?
            !atoms.one? && !symmetric_atoms.empty? &&
              symmetric_atoms.to_set < atoms.to_set
          end

          def to_s
            inspect
          end

          def inspect
            sis = species.map(&:inspect)
            nas = nodes.uniq(&:atom)
            spops = nas.map(&:sub_properties).map(&:inspect)
            pkns = nas.map do |n|
              n.spec.spec.keyname(n.uniq_specie.send(:reflection_of, n.atom))
            end
            ppops = nas.map(&:properties).map(&:inspect)
            ckns = nas.map do |n|
              ds = n.uniq_specie.spec
              ch = ds.instance_variable_get(:@child) || ds
              ch.spec.keyname(n.atom)
            end
            pkwps = pkns.zip(spops).map { |kp| kp.join(':') }
            ckwps = ckns.zip(ppops).map { |kp| kp.join(':') }
            bs = pkwps.zip(ckwps).map { |p, c| "(#{p})‡(#{c})" }
            "•[#{sis.join(' ')}] [#{bs.join(' ')}]•"
          end

        protected

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def redefine_atoms_as_array(&block)
            if atoms.one? || dict.var_of(atoms)
              block.call # all atoms already belongs to same array
            else
              remake_atoms_as_array.define_var + block.call
            end
          end

        private

          # @param [BasePureUnit] other
          # @return [Proc]
          def comparing_core(other)
            -> do
              sps, ops = [self, other].map { |u| u.nodes.map(&:sub_properties) }
              ops <=> sps
            end
          end

          # @param [Symbol] method_name
          # @return [Array]
          def uniq_from_nodes(method_name)
            nodes.map(&method_name).uniq
          end

          # @param [Array] atoms
          # @return [Array]
          def nodes_with_atoms(atoms)
            nodes.select { |node| atoms.include?(node.atom) }
          end

          # @param [Array] species
          # @return [Array]
          def nodes_with_species(species)
            nodes.select { |node| species.include?(node.uniq_specie) }
          end

          # @param [BasePureUnit] inner_unit
          # @return [Array]
          def split_on_compliance(inner_unit)
            complete_unit?(inner_unit) ? [inner_unit] : inner_unit.units
          end

          # @param [BasePureUnit] inner_unit
          # @return [Boolean]
          def complete_unit?(inner_unit)
            !inner_unit.atoms.one? || coincident_nodes_of?(inner_unit)
          end

          # @param [BasePureUnit] inner_unit
          # @return [Boolean]
          def coincident_nodes_of?(inner_unit)
            values = inner_unit.nodes.map(&:coincide?)
            !values.any? || values.all?
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_undefined_species(&block)
            var = make_undefined_species_from_anchors
            checking_exprs = var.collection? ? var.items : [var]
            var.define_var +
              Expressions::AndCondition[checking_exprs, block.call]
          end

          # @return [Array]
          def defined_symmetric_species
            symmetric_nodes = nodes.select(&:symmetric_atoms?)
            if symmetric_nodes.empty?
              select_defined(species)
            else
              select_defined(symmetric_nodes.map(&:uniq_specie).uniq)
            end
          end

          # @param [BasePureUnit] nbr
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_amorph_bonds(nbr, &block)
            predefn_vars = dict.defined_vars # get before make inner nbr atoms var
            atom_var = dict.var_of(atoms)
            nbr_var = dict.make_atom_s(nbr.atoms)
            if !atoms.any?(&:lattice) && nbr.atoms.any?(&:lattice)
              atom_var.iterate_crystal_nbrs(predefn_vars, nbr_var, block.call)
            else
              atom_var.iterate_amorph_nbrs(predefn_vars, nbr_var, block.call)
            end
          end

          # @param [Instances::SpecieInstance] specie
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_defined_specie_symmetries(specie, &block)
            predefn_vars = dict.defined_vars # get before make inner specie var
            ext_var = dict.var_of(specie)
            options = { type: abstract_type, name: specie.symmetric_var_name }
            inner_var = dict.make_specie_s(specie, **options)
            ext_var.iterate_symmetries(predefn_vars, inner_var, block.call)
          end

          # @return [Expressions::Core::Variable]
          def make_undefined_atoms_from_defined_species
            undefined_atoms = select_undefined(atoms)
            vars = vars_for(nodes_with_atoms(undefined_atoms).map(&:uniq_specie))
            pairs = vars.smart_zip(undefined_atoms).select(&:first)
            calls = pairs.map { |v, a| v.atom_value(a) }
            selected_atoms = pairs.map(&:last)
            if selected_atoms.one? && calls.size > 1
              dict.make_atom_s(selected_atoms.first, value: calls.first)
            else
              dict.make_atom_s(selected_atoms, value: calls)
            end
          end

          # @return [Expressions::Core::Variable]
          def make_undefined_species_from_anchors
            undefined_species = select_undefined(anchored_species).sort
            vars = vars_for(nodes_with_species(undefined_species).map(&:atom))
            calls = vars.zip(undefined_species).map { |v, s| v.one_specie_by_role(s) }
            kwargs = { value: calls }
            kwargs[:type] = abstract_type unless undefined_species.one?
            dict.make_specie_s(undefined_species, **kwargs)
          end

          # @param [BasePureUnit] nbr
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def redefine_self_and_nbr_atoms_if_need(nbr, &block)
            redefine_atoms_as_array do
              if all_defined?(nbr.atoms)
                nbr.redefine_atoms_as_array(&block)
              else
                block.call
              end
            end
          end

          # @return [Expressions::Core::Collection]
          def remake_atoms_as_array
            dict.make_atom_s(atoms, value: vars_for(atoms))
          end

          # @param [Array] packing_atoms
          # @yield [SpecieInstance, Atom] checks that atom belongs to specie
          # @return [Array]
          def pack_with_species(packing_atoms, &block)
            packing_atoms.zip(packing_species(packing_atoms, &block))
          end

          # @param [Array] packing_atoms
          # @yield [SpecieInstance, Atom] checks that atom belongs to specie
          # @return [Array]
          def packing_species(packing_atoms, &block)
            packing_atoms.map { |atom| chose_specie_with(atom, &block) }
          end

          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   packing_atom the specie for which will be chosed
          # @yield [SpecieInstance, Atom] checks that atom belongs to specie
          # @return [Instances::SpecieInstance]
          def chose_specie_with(packing_atom, &block)
            species.find { |specie| block[specie, packing_atom] }
          end
        end

      end
    end
  end
end
