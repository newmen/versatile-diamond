module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building reaction check laterals algorithm
        class ReactionCheckLateralsBuilder < BaseAlgorithmBuilder

          # Inits builder
          # @param [EngineCode] generator the major engine code generator
          # @param [Array] lateral_reactions the list of reactions which existance
          #  should be checked
          # @param [LateralChunks] lateral_chunks the target object by which the
          #   algorithm will be generated
          # @param [Specie] specie from which the algorithm will be builded
          def initialize(generator, lateral_reactions, lateral_chunks, specie)
            @lateral_reactions = lateral_reactions
            @lateral_chunks = lateral_chunks
            @specie = specie
            super(generator)
          end

          # Generates check laterals algorithm cpp code
          # @return [String] the string with cpp code of check laterals algorithm
          def build
          end

        private


        end

      end
    end
  end
end
