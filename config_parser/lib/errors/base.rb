module VersatileDiamond
  module Errors

    # Implements exception for raising when syntax of config file is wrong
    class Base < ::SyntaxError
      # Fits message to a line in the file
      # @param [String] the path to file
      # @param [Integer] the line number
      # @param [Array] args the another arguments for super if exists
      # @return [String] the message about error
      def message(*args)
        case args.size
        when 1
          line_number = args.first
        when 2
          file, line_number = *args
        end

        tail = file ? "\n\tfrom #{file}:" : ''
        if line_number
          tail << ' at line ' unless file
          tail << line_number.to_s
        end
        tail == '' ? super : "#{super()}#{tail}"
      end
    end

  end
end
