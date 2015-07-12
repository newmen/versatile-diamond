module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The class for look around algorithm builder units with many species
        class ManyLateralChunksUnit < BaseManyReactantsUnit
          include LateralChunksUnitBehavior
          include OtherSideRelationsCppExpression

          # Initializes the unit of code builder algorithm
          # @param [Array] args of base class constructor
          # @param [LateralChunks] lateral_chunks by which the relations between atoms
          #   will be checked
          def initialize(*args, lateral_chunks)
            super(*args)
            @lateral_chunks = lateral_chunks
          end

          def inspect
            "MLCSU:(#{inspect_species_atoms_names}])"
          end

          # Assigns the name for internal reactant species, that it could be used when
          # the algorithm generates
          def first_assign!
            if all_species_are_targets?
              target_species.each do |uniq_specie|
                namer.assign(reactant_specie_var_name(uniq_specie), uniq_specie)
              end
            else
              namer.assign(SpeciesReaction::ANCHOR_SPECIE_NAME, target_species)
            end
          end

        private

          attr_reader :lateral_chunks

          # Checks that all species are target
          # @return [Boolean] are all species targets or not
          def all_species_are_targets?
            target_species.all? do |uniq_specie|
              lateral_chunks.target_spec?(uniq_specie.proxy_spec.spec)
            end
          end
        end

      end
    end
  end
end
