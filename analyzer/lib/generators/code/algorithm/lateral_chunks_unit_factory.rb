module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction look around algorithm units
        class LateralChunksUnitsFactory < BaseReactionUnitsFactory

          # Initializes reaction look around algorithm units factory
          # @param [EngineCode] generator the major code generator
          # @param [LateralChunks] lateral_chunks for which the algorithm is building
          def initialize(generator, lateral_chunks)
            super(generator)
            @lateral_chunks = lateral_chunks
          end

          # Gets the lateral chunk creator unit
          # @param [LateralReaction] lateral_reaction instance of which will allocated
          # @param [Array] sidepiece_species required for creation lateral reaction
          # @return [ReactionCreatorUnit] the unit for defines lateral chunk creation
          #   code block
          def creator(lateral_reaction, sidepiece_species)
            args = [namer, lateral_reaction, sidepiece_species]
            SingleLateralReactionCreatorUnit.new(*args)
          end

        private

          # Makes unit which contains one specie
          # @param [Array] nodes from which the unit will be created
          # @return [LateralChunkUnit] which contains one unique specie
          def make_single_unit(nodes)
            LateralChunkUnit.new(*single_unit_args(nodes), @lateral_chunks)
          end

          # Makes unit which contains many reactant species
          # @param [Array] nodes from which the unit will be created
          # @return [ManyLateralChunksUnit] which contains many unique specie
          def make_multi_unit(nodes)
            ManyLateralChunksUnit.new(*multi_unit_args(nodes), @lateral_chunks)
          end
        end

      end
    end
  end
end
