module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code that depends from reactant specie
        class ReactantUnit < SingleReactantUnit
          include ReactantUnitBehavior

          # Initializes the reactant unit
          # @param [Array] args the arguments of #super method
          # @param [Organizers::DependentTypicalReaction] dept_reaction by which the
          #   relations between atoms will be checked
          def initialize(*args, dept_reaction)
            super(*args)
            @dept_reaction = dept_reaction
          end

          # Checks non compliance atoms which should not be available from other atoms
          # @param [Array] atoms_to_rels the hash of own atoms to using relations
          # @yield should get cpp code string which is body of checking
          # @return [String] the cpp code string
          def check_compliances(atoms_to_rels, &block)
            define_target_specie_line +
              check_symmetries(closure: true) do
                compliances_condition(atoms_to_rels, &block)
              end
          end

          # Assigns the name for internal reactant specie, that it could be used when
          # the algorithm generates
          def first_assign!
            namer.assign(SpeciesReaction::ANCHOR_SPECIE_NAME, target_specie)
          end

        private

          attr_reader :dept_reaction

          # Gets the checking block for atoms by which the grouped graph was extended
          # @param [Hash] atoms_to_rels own atoms to using relations
          # @yield should get cpp code string which is body of checking
          # @return [String] the cpp code string
          def compliances_condition(atoms_to_rels, &block)
            code_condition(compliances_compares(atoms_to_rels).join(' && '), &block)
          end

          # Gets the list of string compares by passed map
          # @param [Hash] atoms_to_rels own atoms to using relations
          # @return [Array] the list of string conditions which will be joined
          def compliances_compares(atoms_to_rels)
            compliances_atoms(atoms_to_rels).map do |atom|
              op = atoms_to_rels[atom].exist? ? '==' : '!='
              "#{name_of(atom)} #{op} #{atom_from_own_specie_call(atom)}"
            end
          end

          # Gets the list of atoms which compliences should be checked
          # @param [Hash] atoms_rels own atoms to using relations
          # @return [Array] the list of atoms which will be complianced
          def compliances_atoms(atoms_rels)
            all_atoms_symmetric? ? atoms : atoms_rels.reject { |_, r| r.exist? }.keys
          end
        end

      end
    end
  end
end
