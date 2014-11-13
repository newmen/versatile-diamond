module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The base class for algorithm builder units
        # @abstract
        class BaseUnit
          include CommonCppExpressions
          include NeighboursCppExpressions
          extend Forwardable

          # Initializes the empty unit of code builder algorithm
          # @param [EngineCode] generator the major code generator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [Specie] original_specie which uses in current building algorithm
          def initialize(generator, namer, original_specie, atoms)
            @generator = generator
            @namer = namer
            @original_specie = original_specie
            @atoms = atoms
          end

        protected

          attr_reader :atoms

          # Atomic specie is always single
          # @return [Boolean] true
          def single?
            atoms.size == 1
          end

          # Are all atoms has lattice
          # @return [Boolean] are all atoms or not
          def latticed?
            atoms.all?(&:lattice)
          end

          # Checks that atom has a bond like the passed
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which relations in current specie will be checked
          # @param [Concepts::Bond] bond which existance will be checked
          # @return [Boolean] is atom uses bond in current specie or not
          def use_bond?(atom, bond)
            spec.relations_of(atom).any? { |r| r == bond }
          end

          # Selects most complex target atom
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the most target atom of original specie
          def target_atom
            @_target_atom ||= atoms.max_by do |atom|
              Organizers::AtomProperties.new(spec, atom)
            end
          end

          # Gets a code which uses eachNeighbour method of engine framework and checks
          # role of iterated neighbour atoms
          #
          # @param [BaseUnit] other the unit with neighbour atoms to which iteration
          #   will do
          # @param [Hash] rel_params the relation parameters through which neighbours
          #   was gotten
          # @yield should return cpp code string of lambda body
          # @return [String] the string with cpp code
          # @override
          def each_nbrs_lambda(other, rel_params, &block)
            nbrs = other.atoms
            defined_nbrs_with_names = nbrs.map { |nbr| [nbr, namer.name_of(nbr)] }
            defined_nbrs_with_names.select!(&:last)
            namer.erase(nbrs)

            super(other, rel_params) do
              condition =
                if defined_nbrs_with_names.empty?
                  other.check_role_condition
                else
                  new_names = nbrs.map { |n| namer.name_of(n) }
                  prv_names = defined_nbrs_with_names.map(&:last)
                  comp_strs = prv_names.zip(new_names).map { |nms| nms.join(' == ') }
                  comp_strs.join(' && ')
                end

              units_with_atoms = append_units(other, atoms.zip(nbrs))
              condition = append_check_bond_condition(condition, units_with_atoms)
              code_condition(condition, &block)
            end
          end

          # Gets a cpp code string that contain call a method for check atom role
          # @param [Array] atoms which role will be checked in code
          # @return [String] the string with cpp condition
          def check_role_condition
            combine_condition(atoms, '&&') do |var, atom|
              "#{var}->is(#{role(atom)})"
            end
          end

        private

          attr_reader :generator, :namer, :original_specie
          def_delegators :original_specie, :spec, :role

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_name_of(obj)
            namer.name_of(obj) || 'undef'
          end

          # Gets the variable name of target atom
          # @return [String] the variable name of target atom
          def target_atom_var_name
            namer.name_of(target_atom)
          end
        end

      end
    end
  end
end
