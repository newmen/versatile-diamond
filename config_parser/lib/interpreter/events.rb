module VersatileDiamond
  module Interpreter

    # Interprets events block, which can contain description of reactions and
    # environments for them
    class Events < ComplexComponent

      # Interprets the reaction block by delegating permissions for create to
      # reaction interpreter instance
      #
      # @param [String] name the name of reaction
      # TODO: rspec
      def reaction(name)
        nested(Reaction.new(name))
      end

      # def environment(name)
      #   nested(Environment.new(name))
      # end
    end

  end
end
