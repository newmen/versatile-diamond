module VersatileDiamond
  module Interpreter

    # Interprets refinement block and pass setting of each property to concept
    class Refinement < Component
      include ReactionProperties
      include ReactionRefinements

      # Initialize a new interpreter instance
      # @param [Concepts::Reaction] reaction the reaction concept which will be
      #   setuped
      # @param [Hash] names_and_specs see at Equation#initialize same argument
      def initialize(reaction, names_and_specs)
        @reaction, @names_and_specs = reaction, names_and_specs
      end
    end

  end
end
