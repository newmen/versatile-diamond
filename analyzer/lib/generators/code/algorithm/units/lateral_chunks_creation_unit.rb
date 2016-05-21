module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The unit for combines statements of lateral reaction creation
        # @abstract
        class LateralChunksCreationUnit < BaseCreationUnit
          include ReactionCreationMethods

          # @param [Expressions::VarsDictionary] dict
          # @param [ReactionContextProvider] context
          def initialize(dict, context)
            super(dict)
            @context = context

            @_uniq_side_nodes = nil
            @_lateral_reaction = nil
          end

        private

          attr_reader :context

          # @return [Array]
          def grep_context_species
            uniq_side_nodes.map(&:uniq_specie)
          end

          # @return [Array]
          def uniq_side_nodes
            @_uniq_side_nodes ||=
              context.side_nodes.uniq { |node| node.uniq_specie.original }
          end

          # @return [LateralReaction]
          def lateral_reaction
            return @_lateral_reaction if @_lateral_reaction
            reactions = sidepiece_nodes.map(&:lateral_reaction).uniq
            if reactions.one?
              @_lateral_reaction = reactions.first
            else
              raise 'Incorrect number of lateral reactions'
            end
          end

          # @return [Expressions::Core::ObjectType]
          def lateral_reaction_type
            Expressions::Core::ObjectType[lateral_reaction.class_name]
          end
        end

      end
    end
  end
end
