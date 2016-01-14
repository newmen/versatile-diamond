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

          # Gets the role of creating mono unit
          # @return [Module] the scope of methods which defines behavior of unit
          def behavior_role
            Units::LateralBehavior
          end

          # Gets the object which provides global links
          # @return [TypicalReaction] reaction which should be found by building
          #   algorigm
          def relations_checker
            @lateral_chunks
          end

          # Do nothing
          # @param [Instances::SpecieInstance] _
          def remember_uniq_specie(_)
          end
        end

      end
    end
  end
end
