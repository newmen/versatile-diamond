module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building find reaction algorithm
        class ReactionFindBuilder < MainFindAlgorithmBuilder

          # Inits builder by main engine code generator, target reaction and reatant
          # specie which should be found by generating algorithm
          #
          # @param [EngineCode] generator the major engine code generator
          # @param [TypicalReaction] reaction the target reaction code generator
          # @param [Specie] specie the reactant from which the algorithm will be built
          def initialize(generator, reaction, specie)
            super(ReactionBackbone.new(generator, reaction, specie))
            @reaction = reaction
          end

        private

          # @return [ReactionPureUnitsFactory]
          def make_pure_factory
            ReactionPureUnitsFactory.new(dict)
          end

          # @param [Units::ReactionContextProvider] context
          # @return [ReactionContextUnitsFactory]
          def make_context_factory(context)
            ReactionContextUnitsFactory.new(dict, pure_factory, context)
          end

          # @param [Array] ordered_graph
          # @return [Units::ReactionContextProvider]
          def make_context_provider(ordered_graph)
            Units::ReactionContextProvider.new(dict, backbone.big_graph, ordered_graph)
          end

          # @oaram [ReactionContextUnitsFactory] factory
          # @return [Units::ReactionCreationUnit]
          def make_creator_unit(factory)
            factory.creator(@reaction)
          end

          # @param [Units::ContextReactionUnit] _
          # @return [Array]
          def init_procs(_)
            []
          end
        end

      end
    end
  end
end
