module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of constants
        class Constant < Expression
          class << self
            # @param [Object] value
            # @return [Statement]
            def [](value)
              if value.is_a?(String) && side_spaces?(value)
                raise 'Constant cannot contain side space charachters'
              elsif !valid?(value)
                raise %(Wrong type of constant value "#{value}")
              else
                new(value)
              end
            end

          private

            # @param [String] value
            # @return [Boolean]
            def side_spaces?(value)
              !!value.match(/^\s+|\s+$/)
            end

            # @param [Object] value
            # @return [Boolean]
            def valid?(value)
              allowed_types.any? { |klass| klass.is_a?(name) }
            end

            # @return [Array]
            def allowed_types
              [String, Integer, Float]
            end
          end

          # @override
          attr_reader :name

          # @return [String]
          # @override
          def code
            name.to_s
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
