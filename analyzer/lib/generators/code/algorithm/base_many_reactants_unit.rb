module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The base class for reaction algorithm builder units with many original
        # species
        # @abstract
        class BaseManyReactantsUnit < BaseUnit

          # Initializes the base unit of code builder algorithm
          # @param [EngineCode] generator the major code generator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [Hash] atoms_to_species the mirror of atoms to correspond unique
          #   species
          def initialize(generator, namer, atoms_to_species)
            super(generator, namer, atoms_to_species.keys)
            @atoms_to_species = atoms_to_species

            @_target_atom, @_target_species = nil
          end

          # Gets unique specie for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   _ does not used
          # @return [Specie] the unique specie
          def uniq_specie_for(atom)
            @atoms_to_species[atom]
          end

          # Gets correspond original dependent spec for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the original dependent spec will be returned
          # @return [Organizers::DependentWrappedSpec] the internal dependent spec
          def dept_spec_for(atom)
            uniq_specie_for(atom).proxy_spec
          end

          # Checks that passed spec equal to any using specie
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   spec which will checked
          # @return [Boolean] is target spec or not
          def unit_spec?(spec)
            target_species.any? { |target_spec| target_spec.proxy_spec.spec == spec }
          end

          def inspect
            "BMRSU:(#{inspect_species_atoms_names}])"
          end

        private

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_species_atoms_names
            strs = @atoms_to_species.map do |a, s|
              "#{inspect_name_of(s)}:#{s.inspect}·#{inspect_name_of(a)}"
            end
            strs.join('|')
          end

          # Gets the target atom
          # @return [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
          def target_atom
            return @_target_atom if @_target_atom
            pair = @atoms_to_species.max_by do |atom, specie|
              atom_properties(specie.proxy_spec, atom)
            end

            @_target_atom = pair.first
          end

          # Gets the list of internal species
          # @return [Array] the list of using species
          def target_species
            @_target_species ||= @atoms_to_species.values()
          end
        end

      end
    end
  end
end
