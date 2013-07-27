module VersatileDiamond
  module Errors

    class SyntaxError < Exception
      def message(*args)
        if args.size != 2
          super
          return
        end
        line_number, file = *args

        tail = file ? "from #{file}:" : ''
        tail << line_number.to_s
        "#{super()}\n\t#{tail}"
      end
    end

  end
end
