module VersatileDiamond
  module Modules

    # Provides logic for create proxy instances that delegates all method calls to
    # target instance
    class TransparentProxy

      attr_reader :original

      # Initializes proxy instance
      # @param [Object] original to which will delegated all method calls
      def initialize(original)
        @original = original
      end

      # Compares current instance with other
      # @param [Object] other instance with which comparison do
      # @return [Boolean] is equal or not
      def == (other)
        other.class == self.class ? super(other) : @original == other
      end

      # Delegates all available another calls to original spec
      def method_missing(*args)
        @original.public_send(*args)
      end

      def inspect
        "proxy:#{@original.inspect}"
      end
    end

  end
end
