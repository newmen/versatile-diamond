module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides logic for units which uses when look around algorithm builds
        module LateralBehavior
          include Algorithm::Units::ReactantUnitCommonBehavior
          include Algorithm::Units::LateralSpecDefiner

          # Gets code line with definition of target species atoms
          # @return [String] the code line with defined atoms
          def define_target_atoms_line
            values = names_or(atoms) do |atom|
              atom_from_specie_call(uniq_specie_for(atom), atom)
            end

            namer.erase(atoms)
            namer.assign_next(Specie::INTER_ATOM_NAME, atoms)
            define_var_line('Atom *', atoms, values)
          end

        private

          # Gets the name of variable for target specie
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   concept_spec which index will be checked in the list of target specs
          # @return [String] the name which will first assigned
          def reactant_specie_var_name(concept_spec)
            "target(#{lateral_chunks.reaction.target_index(concept_spec)})"
          end
        end

      end
    end
  end
end
