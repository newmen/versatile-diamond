module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The basic unit for each other
        # @abstract
        class BaseUnit < GenerableUnit
          include Modules::ProcsReducer

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

          # @param [Array] nodes
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: just specie
          def check_different_atoms_roles(nodes, &block)
            checking_nodes = nodes.select(&:different_atom_role?)
            if checking_nodes.empty?
              block.call
            else
              check_atoms_roles(checking_nodes.map(&:atom), &block)
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_symmetries(&block)
            if species.one? || atoms.one?
              iterate_specie_symmetries(&block)
            else # if asymmetric_related_atoms?
              iterate_for_loop_symmetries(&block)
            end
          end

          # @param [Array] undefined_atoms
          # @return [Expressions::Core::Assign]
          def define_undefined_atoms(undefined_atoms)
            make_atoms_from_species(undefined_atoms).define_var
          end

        private

          # @param [Symbol] method_name
          # @return [Array]
          def uniq_from_nodes(method_name)
            @nodes.map(&method_name).uniq
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

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_specie_symmetries(&block)
            defined_species = select_defined(species)
            if defined_species.one?
              iterate_redefined_specie_symmetries(defined_species.first, &block)
            elsif defined_species.empty?
              raise 'Symmetric specie is not defined'
            else
              raise 'Too many defined symmetric species'
            end
          end

          # @param [Instances::SpecieInstance] specie
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_redefined_specie_symmetries(specie, &block)
            defined_vars = dict.defined_vars # get before make inner specie var
            ext_var = dict.var_of(specie)
            inner_var = dict.make_specie_s(specie, type: abst_specie_type)
            ext_var.iterate_symmetries(defined_vars, inner_var, block.call)
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_for_loop_symmetries(&block)
            define_required_atoms do
              redefine_atoms_as_array do
                Expressions::SymmetricAtomsForLoop[vars_for(atoms), block.call]
              end
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def define_required_atoms(&block)
            undefined_atoms = select_undefined(atoms)
            if undefined_atoms.empty?
              block.call
            else
              define_undefined_atoms(undefined_atoms) + block.call
            end
          end

          # @param [Array] undefined_atoms
          # @return [Array]
          def make_atoms_from_species(undefined_atoms)
            nodes = @unit.nodes_with(undefined_atoms)
            species_vars = vars_for(nodes.map(&:uniq_specie))
            atoms_calls =
              species_vars.zip(undefined_atoms).map { |v, a| v.atom_value(a) }

            dict.make_atoms_s(undefined_atoms, value: atoms_calls)
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def redefine_atoms_as_array(&block)
            if atoms.one? || dict.var_of(atoms)
              block.call # all atoms already belongs to same array
            else
              remake_atoms_as_array + block.call
            end
          end

          # @return [Array]
          def remake_atoms_as_array
            dict.make_atoms_s(atoms, value: atoms)
          end

          # @return [Expressions::Core::ObjectType]
          # TODO: just specie
          def abst_specie_type
            Expressions::ParentSpecieType[]
          end
        end

      end
    end
  end
end
