module VersatileDiamond

  module Errors

    class SyntaxError < Exception
      def message(line_number, file = nil)
        tail = file ? 'from #{file}:' : ''
        tail << line_number.to_s
        "#{super}\n\t#{tail}"
      end
    end

  end

end
