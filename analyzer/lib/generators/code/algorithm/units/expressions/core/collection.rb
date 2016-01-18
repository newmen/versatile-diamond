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
          def initialize(namer, instances, type, name, values = nil, **next_name)
            arr_name, vars =
              convert_to_vars(namer, instances, type, name, values, **next_name)

            super(namer, vars, type, arr_name, values)
          end

          # @return [Variable] the variable instance
          def [](index)
            instance[index]
          end

          # @raise [Exception]
          # @override
          def call(*exprs)
            example = instance.first.call(*exprs)
            raise "Collection expression cannot be called (try: #{example})"
          end

        private

          # @param [NameRemember] namer
          # @param [Array] instances
          # @param [Type] type
          # @param [String] name which will be pluralized
          # @param [Array] values
          # @return [Array] first: assigned name of array, second: list of variables
          def convert_to_vars(namer, instances, type, name, values = nil, **next_name)
            arr_name = assign_name!(instances, name, **next_name)

            names = instances.map(&namer.method(&:name_of))
            fixed_values = values || [nil].cycle
            triples = instances.zip(names, fixed_values)

            [arr_name, triples.map { |i, n, v| Variable[namer, i, type, n, v] }]
          end

          # @return [Statement]
          def full_name
            name + OpSquireBks[Constant[instances.size]]
          end

          # @return [Statement] initial value of array or nil
          def rvalue
            super && OpBraces[OpSequence[*super], multiline: false]
          end
        end

      end
    end
  end
end
