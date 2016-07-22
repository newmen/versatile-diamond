module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Contain logic for building algorithm of reaction applying
        class ReactionDoItBuilder < BaseAlgorithmBuilder
          extend Forwardable

          # Initializes algorithm builder
          # @param [EngineCode] generator the major engine code generator
          # @param [TypicalReaction] reaction the target reaction code generator
          def initialize(generator, reaction)
            @factory = ReactionDoItUnitsFactory.new(Changes.new(generator, reaction))
          end

        private

          # @return [Units::Expressions::Core::OpCombine]
          def complete_algorithm
            @factory.sources_unit.define +
              @factory.changes_unit.apply +
              @factory.close_unit.finish
          end
        end

      end
    end
  end
end
