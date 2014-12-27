module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The base class for algorithm builder units with many original species
        class ManyReactantsUnit < BaseUnit
          include ReactionUnitBehavior

          # Initializes the simple unit of code builder algorithm
          # @param [EngineCode] generator the major code generator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [Hash] atoms_to_specs the mirror of atoms to correspond specs
          # @param [DependentSpecReaction] dept_reaction by which the relations between
          #   atoms will be checked
          def initialize(generator, namer, atoms_to_specs, dept_reaction)
            super(generator, namer, atoms_to_specs.keys)
            @atoms_to_specs = atoms_to_specs
            @dept_reaction = dept_reaction
          end

          # Checks that atom has a bond like the passed
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which relations in current specie will be checked
          # @param [Concepts::Bond] bond which existance will be checked
          # @return [Boolean] is atom uses bond in current specie or not
          def use_bond?(atom, bond)
            atoms_to_specs[atom].relations_of(atom).any? { |r| r == bond }
          end

          def inspect
            "MRSU:(#{inspect_species_atoms_names}])"
          end

        private

          attr_reader :atoms_to_specs, :dept_reaction

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_species_atoms_names
            atoms_to_specs.reduce('') do |acc, (a, s)|
              acc << "#{inspect_name_of(s)}:#{s.inspect}·#{inspect_name_of(a)}"
            end
          end

          # Gets correspond original dependent spec for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the original dependent spec will be returned
          # @return [Organizers::DependentWrappedSpec] the internal dependent spec
          def dept_spec_for(atom)
            atoms_to_specs[atom]
          end

          # Gets the index of passed atom from generator's classifer by original spec
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be classified
          # @return [Integer] the role of passed atom
          def role(atom)
            generator.classifier.index(atoms_to_specs[atom], atom)
          end
        end

      end
    end
  end
end
