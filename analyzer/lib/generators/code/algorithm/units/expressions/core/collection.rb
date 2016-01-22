module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of array variables
        class Collection < Variable

          # @param [NameRemember] namer
          # @param [Array] instances
          # @param [Type] type
          # @param [String] name which will be pluralized
          # @param [Array] values
          # @param [Hash] kwargs
          def initialize(namer, instances, type, name, values = nil, **kwargs)
            arr_name, vars =
              convert_to_vars(namer, instances, type, name, values, **kwargs)

            super(namer, vars, type, arr_name, values)
          end

          # @param [String] method_name
          # @raise [Exception]
          # @override
          def call(method_name, *)
            raise "Collection #{method_name.inspect} cannot be called for collection"
          end

        private

          # @param [NameRemember] namer
          # @param [Array] instances
          # @param [Type] type
          # @param [String] name which will be pluralized
          # @param [Array] values
          # @param [Hash] kwargs
          # @return [Array] first: assigned name of array, second: list of variables
          def convert_to_vars(namer, instances, type, name, values = nil, **kwargs)
            arr_name = assign_name!(instances, name, **kwargs)

            names = instances.map(&namer.public_method(:name_of))
            triples = instances.zip(names, values || [nil].cycle)

            [arr_name, triples.map { |i, n, v| Variable[namer, i, type, n, v] }]
          end

          # @return [OpCombine]
          def full_name
            super + OpSquireBks[Constant[instances.size]]
          end

          # @return [OpBraces] initial value of array or nil
          def rvalue
            super && OpBraces[OpSequence[*super], multilines: false]
          end

          # @return [Type]
          def arg_type
            super.ptr
          end
        end

      end
    end
  end
end
