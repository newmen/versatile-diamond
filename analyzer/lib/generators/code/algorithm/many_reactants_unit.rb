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
          # @param [Hash] atoms_to_species the mirror of atoms to correspond unique
          #   species
          # @param [DependentSpecReaction] dept_reaction by which the relations between
          #   atoms will be checked
          def initialize(generator, namer, atoms_to_species, dept_reaction)
            super(generator, namer, atoms_to_species.keys)
            @atoms_to_species = atoms_to_species
            @dept_reaction = dept_reaction

            @_target_atom = nil
          end

          # Gets unique specie for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   _ does not used
          # @return [Specie] the unique specie
          def uniq_specie_for(atom)
            atoms_to_species[atom]
          end

          def inspect
            "MRSU:(#{inspect_species_atoms_names}])"
          end

        private

          attr_reader :atoms_to_species, :dept_reaction

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_species_atoms_names
            strs = atoms_to_species.map do |a, s|
              "#{inspect_name_of(s)}:#{s.inspect}·#{inspect_name_of(a)}"
            end
            strs.join('|')
          end

          # Gets the lattice from target atom
          # @return [Concepts::Lattice] the target lattice
          def target_atom
            return @_target_atom if @_target_atom
            pair = atoms_to_species.max_by do |atom, specie|
              Organizers::AtomProperties.new(specie.proxy_spec, atom)
            end

            @_target_atom = pair.first
          end

          # Gets correspond original dependent spec for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the original dependent spec will be returned
          # @return [Organizers::DependentWrappedSpec] the internal dependent spec
          def dept_spec_for(atom)
            uniq_specie_for(atom).proxy_spec
          end
        end

      end
    end
  end
end
