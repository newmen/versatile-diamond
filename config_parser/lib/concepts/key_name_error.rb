module VersatileDiamond

  module Concepts

    # Exception of some key name wrongs, which contain info about it
    class KeyNameError < Exception
      attr_reader :key, :name, :type

      # @param [Symbol] key the underscored concept class name
      # @param [Symbol] name the name of concept
      # @param [Symbol] type of error
      def initialize(key, name, type)
        @key, @name, @type = key, name, type
      end
    end

  end

end
