module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The base class for specie algorithm builder units
        # @abstract
        class BaseSpecieUnit < BaseUnit
          include CommonCppExpressions
          include NeighboursCppExpressions
          extend Forwardable

          # By default assigns internal anchor atoms to some names for using its in
          # find algorithm
          def first_assign!
            namer.assign(Specie::ANCHOR_ATOM_NAME, atoms)
          end

          # Gets the code which checks that containing in unit instance is presented
          # or not
          #
          # @param [String] else_prefix which will be used if current instance has
          #   a several anchor atoms
          # @yield should return cpp code which will be used if unit instance is
          #   presented
          # @return [String] the cpp code string
          def check_existence(else_prefix = '', &block)
            define_anchor_atoms_lines +
              code_condition(check_role_condition(atoms), else_prefix) do
                code_condition(check_specie_condition(atoms), &block)
              end
          end

          # Does nothing by default
          # @yield should return cpp code
          # @return [String] the cpp code string
          def check_species(&block)
            block.call
          end

        protected

          # Atomic specie is always single
          # @return [Boolean] true
          def single?
            atoms.size == 1
          end

          # Gets a code which uses eachNeighbour method of engine framework and checks
          # role of iterated neighbour atoms
          #
          # @param [Array] nbrs the neighbour atoms to which iteration will do
          # @param [Hash] rel_params the relation parameters through which neighbours
          #   was gotten
          # @yield should return cpp code string of lambda body
          # @return [String] the string with cpp code
          # @override
          def each_nbrs_lambda(nbrs, rel_params, &block)
            defined_nbrs_with_names = nbrs.map { |nbr| [nbr, namer.name_of(nbr)] }
            defined_nbrs_with_names.select!(&:last)
            namer.erase(nbrs)

            super(nbrs, rel_params) do
              condition =
                if defined_nbrs_with_names.empty?
                  check_role_condition(nbrs)
                else
                  new_names = nbrs.map { |n| namer.name_of(n) }
                  prv_names = defined_nbrs_with_names.map(&:last)
                  comp_strs = prv_names.zip(new_names).map { |nms| nms.join(' == ') }
                  comp_strs.join(' && ')
                end

              condition = append_check_bond_condition(condition, atoms.zip(nbrs))
              code_condition(condition, &block)
            end
          end

        private

          def_delegators :original_specie, :spec, :role
          def_delegator :spec, :relation_between

          # By default doesn't define anchor atoms
          # @return [String] the empty string
          def define_anchor_atoms_lines
            ''
          end

          # Gets the name of main atoms variable
          # @return [String] the name of defined atoms variable
          def atoms_var_name
            namer.name_of(atoms)
          end

          # Selects most complex target atom
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the most target atom of original specie
          def target_atom
            @_target_atom ||= atoms.max_by do |atom|
              Organizers::AtomProperties.new(spec, atom)
            end
          end

          # Gets the variable name of target atom
          # @return [String] the variable name of target atom
          def target_atom_var_name
            namer.name_of(target_atom)
          end

          # Checks that atom has a bond like the passed
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which relations in current specie will be checked
          # @param [Concepts::Bond] bond which existance will be checked
          # @return [Boolean] is atom uses bond in current specie or not
          def use_bond?(atom, bond)
            spec.relations_of(atom).any? { |_, r| r == bond }
          end

          # Are all atoms has lattice
          # @return [Boolean] are all atoms or not
          def latticed?
            atoms.all?(&:lattice)
          end

          # Gets a cpp code string that contain call a method for check existing
          # current specie in atom
          #
          # @param [Array] atoms which role will be checked in code
          # @return [String] the string with cpp condition
          def check_specie_condition(atoms)
            method_name = original_specie.find_endpoint? ? 'hasRole' : 'checkAndFind'
            combine_condition(atoms, '||') do |var, atom|
              "!#{var}->#{method_name}(#{original_specie.enum_name}, #{role(atom)})"
            end
          end

          # Gets a cpp code string that contain call a method for check atom role
          # @param [Array] atoms which role will be checked in code
          # @return [String] the string with cpp condition
          def check_role_condition(atoms)
            combine_condition(atoms, '&&') do |var, atom|
              "#{var}->is(#{role(atom)})"
            end
          end
        end

      end
    end
  end
end
