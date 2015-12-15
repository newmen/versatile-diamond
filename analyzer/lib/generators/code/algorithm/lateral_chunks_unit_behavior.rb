module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides logic for units which uses when look around algorithm builds
        module LateralChunksUnitBehavior
          include Algorithm::ReactantUnitCommonBehavior
          include Algorithm::LateralSpecDefiner

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

          # Gets the instance which can check the relation between units
          # @return [LateralChunks] the target lateral chunks instance
          def relations_checker
            lateral_chunks
          end

          # Gets the name of variable for target specie
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   concept_spec which index will be checked in the list of target specs
          # @return [String] the name which will first assigned
          def reactant_specie_var_name(concept_spec)
            index = lateral_chunks.reaction.target_index(concept_spec)
            "target(#{index})"
          end
        end

      end
    end
  end
end
