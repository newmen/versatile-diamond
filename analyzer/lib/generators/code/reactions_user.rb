module VersatileDiamond
  module Generators
    module Code

      # Provides method for getting reaction code class from generator
      module ReactionsUser
      private

        # Gets the reaction class code generator
        # @param [Organizers::DependentReaction] reaction by which code generator
        #   will be gotten
        # @return [BaseReaction] the correspond reaction code generator
        def reaction_class(reaction)
          generator.reaction_class(reaction.name)
        end

        # Gets the list of reaction class code generators
        # @param [Array] reactions by which code generators will be gotten
        # @return [Array] the correspond reaction code generators
        def reaction_classes(reactions)
          reactions.map(&method(:reaction_class))
        end
      end

    end
  end
end
