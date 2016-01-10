module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code that depends from lateral specie
        class LateralChunkUnit < SingleReactantUnit
          include LateralChunksUnitBehavior

          # Initializes the lateral chunk unit
          # @param [Array] args the arguments of #super method
          # @param [LateralChunks] lateral_chunks by which the relations between
          #   atoms will be checked
          def initialize(*args, lateral_chunks)
            super(*args)
            @lateral_chunks = lateral_chunks
          end

          # Assigns the name for internal reactant specie, that it could be used when
          # the algorithm generates
          def first_assign!
            namer.assign(target_specie_var_name, target_specie)
          end

        private

          attr_reader :lateral_chunks

          # Gets the name of variable for target specie
          # @return [String] the name which will first assigned
          def target_specie_var_name
            if lateral_chunks.target_spec?(target_concept_spec)
              reactant_specie_var_name(target_concept_spec)
            else
              SpeciesReaction::ANCHOR_SPECIE_NAME
            end
          end
        end

      end
    end
  end
end
