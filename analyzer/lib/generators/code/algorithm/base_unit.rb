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

          # Initializes the base unit of code builder algorithm
          # @param [EngineCode] generator the major code generator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [Specie] original_specie which uses in current building algorithm
          def initialize(generator, namer, original_specie)
            @generator = generator
            @namer = namer
            @original_specie = original_specie

            @_target_atom = nil
          end

          # By default assigns internal anchor atoms to some names for using its in
          # find algorithm
          def first_assign!
            assign_anchor_atoms!
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
            define_anchor_atoms +
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
                  comp_strs = defined_nbrs_with_names.map do |nbr, prev_name|
                    "#{prev_name} == #{namer.name_of(nbr)}"
                  end
                  comp_strs.join(' && ')
                end

              condition = append_check_bond_condition(condition, atoms.zip(nbrs))
              code_condition(condition, &block)
            end
          end

        private

          attr_reader :generator, :namer, :original_specie
          def_delegators :original_specie, :spec, :role
          def_delegator :spec, :relation_between

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_name_of(obj)
            namer.name_of(obj) || 'undef'
          end

          # By default doesn't define anchor atoms
          # @return [String] the empty string
          def define_anchor_atoms
            ''
          end

          # Stores the name of atoms variable
          def assign_anchor_atoms!
            namer.assign(Specie::ANCHOR_ATOM_NAME, atoms)
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

          # Are all atoms has lattice
          # @return [Boolean] are all atoms or not
          def latticed?
            atoms.all?(&:lattice)
          end

          # Gets a cpp code string that contain call a method for check existing current
          # specie in atom
          #
          # @param [Array] atoms which role will be checked in code
          # @return [String] the string with cpp condition
          def check_specie_condition(atoms)
            has_children_species = !original_specie.non_root_children.empty?
            method_name = has_children_species ? 'checkAndFind' : 'hasRole'
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
