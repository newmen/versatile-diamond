module VersatileDiamond
  module Tools

    # Provides logic for create proxy instances that delegates all method calls to
    # target instance
    class TransparentProxy
      extend Forwardable

      class << self
        # Defines methods delegators to original instance
        # @param [Array] methods the list of available methods
        def delegate(*methods)
          def_delegators(:original, *methods)
        end
      end

      attr_reader :original

      # Initializes proxy instance
      # @param [Object] original to which will delegated all method calls
      # @option [Boolean] :skip_index if passed and true then original instance will
      #   not be cached for counting the indexes of all same created instances
      def initialize(original, skip_index: false)
        @i =
          if skip_index
            'x'
          else
            @@numbers ||= {}
            @@numbers[original] ||= 0
            @@numbers[original] += 1
            @@numbers[original]
          end

        @original = original
      end

      # Default comparation method which compares the originals of tho proxies
      # @param [OtherSideSpecie] other
      # @return [Integer]
      def <=>(other)
        original <=> other.original
      end

      def inspect
        "px_#{i}:#{original.inspect}"
      end

    private

      attr_reader :i

    end

  end
end
