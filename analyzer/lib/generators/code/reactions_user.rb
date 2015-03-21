module VersatileDiamond
  module Generators
    module Code

      # Provides method for getting reaction code class from generator
      module ReactionsUser
      private

        # Gets the reaction class code generator
        # @param [Organizers::DependentReaction] reaction by which code generator
        #   will be gotten
        # @return [Reaction] the correspond reaction code generator
        def reaction_class(reaction)
          generator.reaction_class(reaction.name)
        end
      end

    end
  end
end
