module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Describes array variables
        class Collection < Variable
          class << self
            # @param [NameRemember] namer
            # @param [Array] instances
            # @param [Type] type of collection item
            # @param [String] name which will be pluralized
            # @param [Array] values
            # @param [Hash] nopts
            # @return [Collection]
            def [](namer, instances, type, name, values = nil, **nopts)
              if diff_sizes?(instances, values)
                arg_err!('Number of instances is not equal to number of values')
              elsif arr?(instances)
                name, vars = to_vars(namer, instances, type, name, values, **nopts)
              else
                vars = [Variable[namer, instances, type, name, values, **nopts]]
              end
              super(namer, instances, type, name, values, vars: vars)
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
            # @param [Type] type
            # @param [String] name which will be pluralized
            # @param [Array] values
            # @param [Hash] nopts
            # @return [Array] first is assigned name of array, second is list of vars
            def to_vars(namer, instances, type, name, values = nil, **nopts)
              arr_name = assign_name(namer, instances, name, **nopts)
              names = instances.map(&namer.public_method(:name_of))
              triples = instances.zip(names, values || [nil].cycle)
              [arr_name, triples.map { |i, n, v| Variable[namer, i, type, n, v] }]
            end
          end

          # @param [NameRemember] namer
          # @param [Array] insts
          # @param [Type] type
          # @param [String] name which will be pluralized
          # @param [Array] values
          # @option [Array] :vars
          def initialize(namer, insts, type, name, values = nil, vars: [])
            super(namer, insts, type, name, values)
            @vars = vars
          end

          # @param [Integer] index
          # @return [Variable]
          def [](index)
            if one?
              mtd_err!("Current variable isn't collection")
            else
              @vars[index] || arg_err!("Wrong passing index #{index}")
            end
          end

          %i(define_var define_arg).each do |method_name|
            # @return [Assign]
            # @override
            define_method(method_name) do
              one? ? first.public_send(method_name) : super()
            end
          end

          # @param [Array] vars
          # @return [Array] list of using variables
          # @override
          def using(vars)
            current, next_vars = self_using(vars)
            current + (value ? @vars.flat_map { |v| v.using(next_vars) } : [])
          end

          # @param [String] method_name
          # @param [Array] args
          # @param [Hash] kwargs
          # @raise [Exception]
          # @override
          def call(method_name, *args, **kwargs)
            if one?
              first.call(method_name, *args, **kwargs)
            else
              mtd_err!("Method #{method_name.inspect} cannot be called for collection")
            end
          end

        private

          def_delegators :@vars, :one?, :first

          # @return [OpCombine]
          # @override
          def full_name
            super + OpSquireBks[Constant[@vars.size]]
          end

          # @return [OpBraces] initial value of array or nil
          # @override
          def value
            super && OpBraces[OpSequence[*super], multilines: false]
          end

          # @return [Type]
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
