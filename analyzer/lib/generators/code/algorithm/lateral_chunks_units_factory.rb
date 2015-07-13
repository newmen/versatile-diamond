module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction lateral chunks algorithms units
        # @abstract
        class LateralChunksUnitsFactory < BaseReactionUnitsFactory

          # Initializes lateral chunks algorithms units factory
          # @param [EngineCode] generator the major code generator
          # @param [LateralChunks] lateral_chunks for which the algorithm is building
          def initialize(generator, lateral_chunks)
            super(generator)
            @lateral_chunks = lateral_chunks
          end

        private

          attr_reader :lateral_chunks

          # Makes unit which contains one specie
          # @param [Array] nodes from which the unit will be created
          # @return [LateralChunkUnit] which contains one unique specie
          def make_single_unit(nodes)
            LateralChunkUnit.new(*single_unit_args(nodes), lateral_chunks)
          end

          # Makes unit which contains many reactant species
          # @param [Array] nodes from which the unit will be created
          # @return [ManyLateralChunksUnit] which contains many unique specie
          def make_multi_unit(nodes)
            ManyLateralChunksUnit.new(*multi_unit_args(nodes), lateral_chunks)
          end
        end

      end
    end
  end
end
