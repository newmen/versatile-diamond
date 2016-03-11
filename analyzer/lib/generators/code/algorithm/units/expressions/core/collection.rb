module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Describes array variables
        class Collection < Variable
          class << self
            # @param [NameRemember] namer
            # @param [Array] instances
            # @param [ScalarType] type of collection item
            # @param [String] name which will be pluralized
            # @param [Array] values
            # @param [Hash] nopts
            # @return [Collection]
            def [](namer, instances, type, name, values = nil, **nopts)
              if diff_sizes?(instances, values)
                arg_err!('Number of instances is not equal to number of values')
              elsif !arr?(instances) || instances.size < 2
                arg_err!('Collection must contain more than one item')
              else
                name, items = to_vars(namer, instances, type, name, values, **nopts)
                # items as option cause super #[] method does not get items
                super(namer, instances, type, name, values, items: items)
              end
            end

          private

            # @param [Array] instances
            # @param [Array] values
            # @return [Boolean]
            def diff_sizes?(instances, values)
              instances && values &&
                arr?(instances) && arr?(values) && instances.size != values.size
            end

            # @param [NameRemember] namer
            # @param [Array] instances
            # @param [ScalarType] type
            # @param [String] name which will be pluralized
            # @param [Array] values
            # @param [Hash] nopts
            # @return [Array] first is assigned name of array, second is list of items
            def to_vars(namer, instances, type, name, values = nil, **nopts)
              arr_name = assign_name(namer, instances, name, **nopts)
              names = instances.map(&namer.public_method(:name_of))
              triples = instances.zip(names, values || [nil].cycle)
              [arr_name, triples.map { |i, n, v| Variable[namer, i, type, n, v] }]
            end
          end

          attr_reader :items

          # @param [NameRemember] namer
          # @param [Array] instances
          # @param [ScalarType] type
          # @param [String] name which will be pluralized
          # @param [Array] values
          # @option [Array] :items (cause super #class.[] method does not get items)
          def initialize(namer, instances, type, name, values = nil, items: [])
            super(namer, instances, type, name, values)
            @items = items
          end

          # @param [Integer] index
          # @return [Variable]
          def [](index)
            @items[index] || arg_err!("Wrong passing index #{index}")
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
            current + (value ? @items.flat_map { |v| v.using(next_vars) } : [])
          end

          # @param [String] method_name
          # @param [Array] args
          # @param [Hash] kwargs
          # @raise [Exception]
          # @override
          def call(method_name, *args, **kwargs)
            mtd_err!("Method #{method_name.inspect} cannot be called for collection")
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

          # @raise [NoMethodError]
          def mtd_err!(msg)
            raise NoMethodError, msg
          end
        end

      end
    end
  end
end
