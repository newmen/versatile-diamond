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
            values = atoms.map do |atom|
              name_of(atom) || atom_from_specie_call(uniq_specie_for(atom), atom)
            end

            namer.erase(atoms)
            namer.assign_next('atom', atoms)
            define_var_line('Atom *', atoms, values)
          end

        private

          # Gets the instance which can check the relation between units
          # @return [LateralChunks] the target lateral chunks instance
          def relations_checker
            lateral_chunks
          end

          # Gets the name of variable for target specie
          # @return [String] the name which will first assigned
          def reactant_specie_var_name(uniq_specie)
            index = lateral_chunks.reaction.target_index(uniq_specie.original)
            "target(#{index})"
          end
        end

      end
    end
  end
end
