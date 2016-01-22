module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of constants
        class Constant < Statement
          extend InitValuesChecker
          include Expression

          class << self
            # @param [String | Integer | Float] value
            # @return [Constant]
            def [](value)
              if side_spaces?(value)
                raise 'Constant cannot contain side space charachters'
              elsif !valid?(value)
                raise "Wrong type of constant value #{value.inspect}"
              else
                super
              end
            end

          private

            # @param [Object] value
            # @return [Boolean]
            def valid?(value)
              allowed_types.any? { |klass| value.is_a?(klass) }
            end

            # @return [Array]
            def allowed_types
              [String, Integer, Float]
            end
          end

          # @param [String | Integer | Float] value
          def initialize(value)
            @value = value.freeze
          end

          # @return [String]
          # @override
          def code
            @value.to_s
          end

          # Checks that current statement is constant
          # @return [Boolean] true
          # @override
          def const?
            true
          end

          # Checks that current statement is scalar value
          # @return [Boolean]
          def scalar?
            [Integer, Float].any? { |klass| @value.is_a?(klass) }
          end

        private

          # @param [Array] vars
          # @return [Array] constant does not use any variable
          # @override
          def using(vars)
            []
          end
        end
      end
    end
  end
end
