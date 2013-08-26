module VersatileDiamond
  module Concepts

    # The base concept class of instances which can be stored in Chest
    # @abstract
    class Named
      attr_reader :name

      # Each concepts should be have name
      def initialize(name)
        @name = name.to_sym
      end

      def to_s
        @name.to_s
      end
    end

  end
end
