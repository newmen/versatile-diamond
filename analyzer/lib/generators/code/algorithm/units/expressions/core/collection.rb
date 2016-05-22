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

          %i(call member).each do |method_name|
            # @param [String] method_name
            # @param [Array] args
            # @param [Hash] kwargs
            # @raise [Exception]
            # @override
            define_method(method_name) do |mn, *args, **kwargs|
              raise NoMethodError, "Method #{mn} cannot be called for collection"
            end
          end

          # @return [Boolean]
          # @override
          def collection?
            true
          end

          # @param [Variable] var
          # @return [Boolean]
          # @override
          def parent_arr?(var)
            items.include?(var)
          end

          # @param [Variable] var
          # @param [Statement] body
          # @return [For]
          def iterate(var, body)
            indexes = [
              var,
              OpMinus[Constant[1].freeze, var].freeze
            ].freeze

            update_indexes!(indexes)

            assign = var.define_var
            cond = OpLess[var, Constant[items.size]]
            op = OpLInc[var]
            For[assign, cond, op, body]
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

          # @param [Array]
          def update_indexes!(indexes)
            if items.size == indexes.size
              items.zip(indexes).each { |v, i| v.update_index!(i) }
            else
              raise ArgumentError, 'Incorrect number of updating indexes'
            end
          end
        end

      end
    end
  end
end
