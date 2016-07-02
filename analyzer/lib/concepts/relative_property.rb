module VersatileDiamond
  module Concepts

    # The base class for relative properties
    # @abstract
    class RelativeProperty
      include MonoInstanceProperty
      include NoBond

      # @return [Integer]
      def hash
        self.class.hash
      end

      # Compares other instance with current
      # @param [TerminationSpec | SpecificSpec] other object with which comparation
      #   will be complete
      # @return [Boolean] is other a instance of same class or not
      def ==(other)
        self.class == other.class
      end
      alias :eql? :==
    end

  end
end
