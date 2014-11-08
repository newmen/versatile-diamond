module VersatileDiamond
  module Tools

    # Provides logic for create proxy instances that delegates all method calls to
    # target instance
    class TransparentProxy

      class << self
        # Available unpublic methods could be defined through it singleton method
        # @param [Array] methods the list of available methods
        def avail_unpublic_methods(*methods)
          @avail_unpublic_methods = methods.to_set
        end

        # Checks that some method is available
        # @param [Symbol] method name
        # @return [Boolean] is available or not
        def avail_method?(method)
          @avail_unpublic_methods && @avail_unpublic_methods.include?(method)
        end
      end

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
        other.class == self.class ? super(other) : original == other
      end

      # Delegates all available another calls to original spec
      def method_missing(*args)
        method_name = args.first
        if TransparentProxy.avail_method?(method_name)
          original.send(*args)
        else
          original.public_send(*args)
        end
      end

      def inspect
        "proxy:#{original.inspect}"
      end
    end

  end
end
