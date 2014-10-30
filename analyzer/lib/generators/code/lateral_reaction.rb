module VersatileDiamond
  module Generators
    module Code

      # Contains logic for generation typical reation
      class LateralReaction < ReactionWithComplexSpecies
      private

        # Gets the parent type of generating reaction
        # @return [String] the parent type of reaction
        # @override
        def outer_base_class_name
          reaction.complexes.empty? ? reaction_type : 'ConcretizableRole'
        end

        # Gets the type of reaction
        # @return [String] the type of reaction
        def reaction_type
          'Lateral'
        end
      end

    end
  end
end
