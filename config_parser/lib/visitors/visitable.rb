using VersatileDiamond::Patches::RichString

module VersatileDiamond
  module Visitors

    # Provides ability for call correspond method of visitor and pass to it
    # self instance
    module Visitable

      # Provides method for to be visitable
      # @param [Visitor] visitor the object which accumulate info about current
      #   instance
      def visit(visitor)
        visitor.send("accept_#{self.class.to_s.underscore}", self)
      end
    end

  end
end
