module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The basic unit for each other
        # @abstract
        class BaseUnit < GenerableUnit

          attr_reader :nodes

          # @param [Expressions::VarsDictionary] dict
          # @param [Array] nodes
          def initialize(dict, nodes)
            super(dict)
            @nodes = nodes

            @_species, @_atoms, @_symmetric_atoms = nil
          end

          # @return [Array]
          def species
            @_species ||= uniq_from_nodes(:uniq_specie)
          end

          # @return [Array]
          def atoms
            @_atoms ||= uniq_from_nodes(:atom)
          end

          # @return [Array]
          def symmetric_atoms
            @_symmetric_atoms ||= nodes.flat_map(&:symmetric_atoms).uniq
          end

          # @param [Array] atoms
          # @return [Array]
          def nodes_with_atoms(atoms)
            nodes.select { |node| atoms.include?(node.atom) }
          end

          # @param [Array] species
          # @return [Array]
          # TODO: must be private (just as #nodes_with_atoms)
          def nodes_with_species(species)
            nodes.select { |node| species.include?(node.uniq_specie) }
          end

          # @param [Symbol] method_name
          # @param [Array] calling_atoms
          # @return [Array]
          def atom_with_specie_calls(method_name, calling_atoms)
            pack_with_species(calling_atoms).map do |atom, specie|
              dict.var_of(atom).public_send(method_name, specie)
            end
          end

          # Checks that atoms have specific types
          # @param [Array] checking_atoms
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_atoms_roles(checking_atoms, &block)
            checks = atom_with_specie_calls(:role_in, checking_atoms)
            Expressions::AndCondition[checks, block.call]
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: just specie (rspec required)
          def check_different_atoms_roles(&block)
            checking_nodes = nodes.select(&:different_atom_role?)
            if checking_nodes.empty?
              block.call
            else
              check_atoms_roles(checking_nodes.map(&:atom), &block)
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_specie_symmetries(&block)
            defined_species = select_defined(species)
            if defined_species.one?
              iterate_defined_specie_symmetries(defined_species.first, &block)
            elsif defined_species.empty?
              raise 'Symmetric specie is not defined'
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
          def iterate_species_by_loop(&block)
            dict.var_of(species).each(block.call)
          end

          # @yield incorporating statement
          # @return [Expressions::Core::OpCall]
          def iterate_species_by_role(&block)
            if atoms.one?
              predefn_vars = dict.defined_vars
              specie_var = dict.make_specie_s(select_undefined(species))
              atom_var = dict.var_of(atoms)
              atom_var.all_species_by_role(predefn_vars, specie_var, block.call)
            else
              raise 'Species iteration by role can occur from just one atom'
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_portions_of_similar_species(&block)
            if atoms.one?
              predefn_vars = dict.defined_vars
              species_var = dict.make_specie_s(select_undefined(species))
              atom_var = dict.var_of(atoms)
              atom_var.species_portion_by_role(predefn_vars, species_var, block.call)
            else
              raise 'Species portion iteration can occur from just one atom'
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def define_undefined_atoms(&block)
            if all_defined?(atoms)
              block.call
            else
              make_undefined_atoms_from_species.define_var + block.call
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def define_undefined_species(&block)
            if all_defined?(species)
              block.call
            else
              make_undefined_species_from_atoms.define_var + block.call
            end
          end

          # @return [Boolean]
          # TODO: required specie specific rspec
          def checkable?
            relayable? && !all_defined?(nodes.select(&:anchor?).map(&:uniq_specie))
          end

          # @return [Boolean]
          # TODO: specie specific rspec already exist
          def neighbour?(unit)
            relayable? && !unit.species.all? { |specie| species.include?(specie) }
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

        private

          # @return [Boolean]
          # TODO: specie specific
          def relayable?
            !species.all?(&:none?)
          end

          # @param [Symbol] method_name
          # @return [Array]
          def uniq_from_nodes(method_name)
            nodes.map(&method_name).uniq
          end

          # @param [Instances::SpecieInstance] specie
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_defined_specie_symmetries(specie, &block)
            predefn_vars = dict.defined_vars # get before make inner specie var
            ext_var = dict.var_of(specie)
            inner_var = dict.make_specie_s(specie, type: abst_specie_type)
            ext_var.iterate_symmetries(predefn_vars, inner_var, block.call)
          end

          # @return [Expressions::Core::Variable]
          def make_undefined_atoms_from_species
            undefined_atoms = select_undefined(atoms)
            vars = vars_for(nodes_with_atoms(undefined_atoms).map(&:uniq_specie))
            calls = vars.zip(undefined_atoms).map { |v, a| v.atom_value(a) }
            dict.make_atom_s(undefined_atoms, value: calls)
          end

          # @return [Expressions::Core::Variable]
          def make_undefined_species_from_atoms
            undefined_species = select_undefined(species)
            vars = vars_for(nodes_with_species(undefined_species).map(&:atom))
            calls = vars.zip(undefined_species).map { |v, s| v.one_specie_by_role(s) }
            dict.make_specie_s(undefined_species, value: calls)
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def redefine_atoms_as_array(&block)
            if atoms.one? || dict.var_of(atoms)
              block.call # all atoms already belongs to same array
            else
              remake_atoms_as_array.define_var + block.call
            end
          end

          # @return [Expressions::Core::Collection]
          def remake_atoms_as_array
            dict.make_atom_s(atoms, value: vars_for(atoms))
          end

          # @param [Array] packing_atoms
          # @return [Array]
          def pack_with_species(packing_atoms)
            packing_atoms.map do |atom|
              [atom, species.find { |specie| specie.anchor?(atom) }]
            end
          end

          # @return [Expressions::Core::ObjectType]
          # TODO: specie specific
          def abst_specie_type
            Expressions::ParentSpecieType[]
          end
        end

      end
    end
  end
end
