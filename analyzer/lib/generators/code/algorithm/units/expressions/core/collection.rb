module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Describes array variables
        class Collection < Variable
          class << self
            # @param [Array] items
            # @param [ScalarType] type of collection item
            # @param [String] name which will be pluralized
            # @param [Array] values
            # @return [Collection]
            def [](items, type, name, values = nil)
              if !arr?(items) || items.size < 2
                arg_err!('Collection must contain more than one item')
              elsif diff_sizes?(items, values)
                arg_err!('Number of items is not equal to number of values')
              else
                super
              end
            end

          private

            # @param [Array] items
            # @param [Array] values
            # @return [Boolean]
            def diff_sizes?(items, values)
              values && arr?(values) && items.size != values.size
            end
          end

          attr_reader :items

          # @param [Array] items
          # @param [ScalarType] type
          # @param [String] name which will be pluralized
          # @param [Array] values
          # @param [Hash] kwargs
          def initialize(items, type, name, values = nil, **kwargs)
            super(items.map(&:instance), type, name, values)
            @items = items
          end

          %i(define_var define_arg).each do |method_name|
            # @return [Assign]
            # @override
            define_method(method_name) { super() }
          end

          # @param [Array] items
          # @return [Array] list of using variables
          # @override
          def using(items)
            current, next_vars = self_using(items)
            current + (value ? items.flat_map { |v| v.using(next_vars) } : [])
          end

          # @param [String] method_name
          # @param [Array] args
          # @param [Hash] kwargs
          # @raise [Exception]
          # @override
          def call(method_name, *args, **kwargs)
            msg = "Method #{method_name.inspect} cannot be called for collection"
            raise NoMethodError, msg
          end

        private

          # @return [OpCombine]
          # @override
          def full_name
            super + OpSquireBks[Constant[@items.size]]
          end

          # @return [OpBraces] initial value of array or nil
          # @override
          def value
            super && OpBraces[OpSequence[*super], multilines: false]
          end

          # @return [ScalarType]
          # @override
          def arg_type
            super.ptr
          end
        end

      end
    end
  end
end
