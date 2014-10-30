module VersatileDiamond
  module Generators
    module Code

      # Contains logic for generation typical reation
      class TypicalReaction < ReactionWithComplexSpecies
      private

        # Gets the parent type of generating reaction
        # @return [String] the parent type of reaction
        # @override
        def outer_base_class_name
          if reaction.complexes.empty?
            reaction_type
          elsif reaction.complexes.all?(&:lateral?)
            'LaterableRole'
          else
            raise 'Тот самый случай'
          end
        end

        # Gets the type of reaction
        # @return [String] the type of reaction
        def reaction_type
          'Typical'
        end
      end

    end
  end
end
