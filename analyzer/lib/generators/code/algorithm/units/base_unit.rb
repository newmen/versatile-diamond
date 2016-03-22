module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The basic unit for each other
        # @abstract
        class BaseUnit < GenerableUnit
          include Modules::ProcsReducer

          attr_reader :nodes

          # @param [Expressions::VarsDictionary] dict
          # @param [Array] nodes
          def initialize(dict, nodes)
            super(dict)
            @nodes = nodes

            @_species, @_atoms = nil
          end

          # @return [Array]
          def species
            @_species ||= uniq_from_nodes(:uniq_specie)
          end

          # @return [Array]
          def atoms
            @_atoms ||= uniq_from_nodes(:atom)
          end

          # @param [Array] atoms
          # @return [Array]
          def nodes_with(atoms)
            nodes.select { |node| atoms.include?(node.atom) }
          end

          # Checks that atoms have specific types
          # @param [Array] checking_atoms
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_atoms_roles(checking_atoms, &block)
            var = dict.var_of(checking_atoms)
            if var # checking atoms belongs to same array variable
              var.check_roles_in(species, block.call)
            else
              nest_checking_atoms_roles(checking_atoms, &block)
            end
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
                Expressions::SymmetricAtomsForLoop[vars_for(atoms), block.call]
              end
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::OpCall]
          def iterate_species_by_role(&block)
            # unit contains just one atom (resolved above)
            predefined_vars = dict.defined_vars
            specie_var = dict.make_specie_s(select_undefined(species))
            atom_var = dict.var_of(atoms)
            atom_var.each_specie_by_role(predefined_vars, specie_var, block.call)
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

          # @return [Boolean]
          # TODO: specie specific (checking none?) (rspec required)
          def checkable?
            !species.any?(&:none?) &&
              !all_defined?(nodes.select(&:anchor?).map(&:uniq_specie))
          end

        private

          # @param [Symbol] method_name
          # @return [Array]
          def uniq_from_nodes(method_name)
            nodes.map(&method_name).uniq
          end

          # @param [Array] checking_atoms
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def nest_checking_atoms_roles(checking_atoms, &block)
            call_procs(checking_atoms_roles_procs(checking_atoms), &block)
          end

          # @param [Array] checking_atoms
          # @return [Array]
          def checking_atoms_roles_procs(checking_atoms)
            vars_for(checking_atoms).map do |atom_var|
              -> &block { atom_var.check_roles_in(species, &block) }
            end
          end

          # @param [Instances::SpecieInstance] specie
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_defined_specie_symmetries(specie, &block)
            predefined_vars = dict.defined_vars # get before make inner specie var
            ext_var = dict.var_of(specie)
            inner_var = dict.make_specie_s(specie, type: abst_specie_type)
            ext_var.iterate_symmetries(predefined_vars, inner_var, block.call)
          end

          # @return [Expressions::Core::Variable]
          def make_undefined_atoms_from_species
            undefined_atoms = select_undefined(atoms)
            species_vars = vars_for(nodes_with(undefined_atoms).map(&:uniq_specie))
            atoms_calls =
              species_vars.zip(undefined_atoms).map { |v, a| v.atom_value(a) }

            dict.make_atom_s(undefined_atoms, value: atoms_calls)
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
            vars = atoms.map(&dict.public_method(:var_of))
            dict.make_atom_s(atoms, value: vars)
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
