module VersatileDiamond

  module Interpreter

    class Events < ComplexComponent
      def reaction(name)
        nested(Reaction.new(name))
      end

      def environment(name)
        nested(Environment.new(name))
      end
    end

  end

end
