module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of constants
        class Constant < Statement
          extend InitValuesChecker
          include Expression

          ALLOWED_TYPES = [Integer, Float, String].freeze

          class << self
            # @param [String | Integer | Float] value
            # @param [Hash] kwargs
            # @return [Constant]
            def [](value, **kwargs)
              if side_spaces?(value)
                arg_err!('Constant cannot contain side space charachters')
              elsif !valid?(value)
                arg_err!("Wrong type of constant value #{value.inspect}")
              else
                super
              end
            end

          private

            # @param [Object] value
            # @return [Boolean]
            def valid?(value)
              ALLOWED_TYPES.any? { |klass| value.is_a?(klass) }
            end
          end

          # @param [String | Integer | Float] value
          def initialize(value)
            @value = value.freeze
          end

          # @return [String]
          # @override
          def code
            value
          end

          # Checks that current statement is constant
          # @return [Boolean] true
          # @override
          def const?
            !!(value =~ /^(?:[0-9]+|[A-Z][0-9A-Z_]*)$/)
          end

          # @param [Array] vars
          # @return [Array] constant does not use any variable
          # @override
          def using(vars)
            []
          end

        private

          # @return [String]
          def value
            @value.to_s
          end
        end
      end
    end
  end
end
