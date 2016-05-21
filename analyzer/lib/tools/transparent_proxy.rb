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

        # Setup the list of binary operations which applies to two proxied entities
        # @param [Array] methods the list of binary operations
        def binary_operations(*methods)
          @binary_operations = methods.to_set
        end

        # Checks that some operation is binary
        # @param [Symbol] operation name
        # @return [Boolean] is binary or not
        def binary_operation?(operation)
          @binary_operations && @binary_operations.include?(operation)
        end

        # Defines comparation method based on original values
        def comparable
          # @param [OtherSideSpecie] other
          # @return [Integer]
          define_method(:'<=>') do |other|
            original <=> other.original
          end
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

      # Delegates all available another calls to original instance
      def method_missing(*args)
        method_name = args.first
        if self.class.avail_method?(method_name)
          original.send(*args)
        elsif args.size == 2 && binary_op?(method_name) && same_class?(args.last)
          original.public_send(method_name, args.last.original)
        else
          original.public_send(*args)
        end
      end

      def inspect
        "proxy_#{i}:#{original.inspect}"
      end

    private

      attr_reader :i

      # Checks that passed entity have the same class
      # @param [Object] other checking entity
      # @return [Boolean] is same or not
      def same_class?(other)
        self.class == args.last.class
      end

      # Delegates to static #binary_operation? method
      # @param [Symbol] operation name
      # @return [Boolean] is binary or not
      def binary_op?(method_name)
        self.class.binary_operation?(method_name)
      end
    end

  end
end
