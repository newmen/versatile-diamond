module VersatileDiamond
  module Interpreter

    # Interprets events block, which can contain description of reactions and
    # environments for them
    class Events < ComplexComponent

      # Interprets the reaction block by delegating permissions for create to
      # reaction interpreter instance
      #
      # @param [String] name the name of reaction concept
      def reaction(name)
        nested(Reaction.new(name))
      end

      # Interprets the environment block, creates environment concept and store
      # it to Chest
      #
      # @param [String] name the name of environment concept
      # @raise [Errors::SyntaxError] if environment concept with same name
      #   already stored
      def environment(name)
        concept = Concepts::Environment.new(name)
        store(concept)
        nested(Environment.new(concept))
      end
    end

  end
end
