module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of class types
        class ScalarType < Constant
          class << self
            # @param [Object] name
            # @param [Hash] kwargs
            # @return [ScalarType]
            def [](name, **kwargs)
              if !str?(name)
                arg_err!("Wrong type name #{name.inspect}")
              elsif empty?(name)
                arg_err!('Scalar type name cannot be empty')
              else
                super
              end
            end
          end

          # @param [ScalarType] other
          # @return [Boolean]
          def ==(other)
            code == other.code
          end

          # @return [String]
          def name
            code
          end

          # Checks that current statement is expression
          # @return [Boolean] false
          # @override
          def expr?
            false
          end

          # Checks that current statement is constant
          # @return [Boolean] false
          # @override
          def const?
            false
          end

          # Checks that current statement is type
          # @return [Boolean] true
          # @override
          def type?
            true
          end

          # Checks that current type is scalar
          # @return [Boolean] true
          def scalar?
            true
          end

          # Checks that current type is pointer
          # @return [Boolean]
          def ptr?
            !!(value =~ /\*$/)
          end

          # @return [ScalarType]
          def ptr
            before = ptr? ? value : "#{value} "
            ScalarType["#{before}*"]
          end
        end

      end
    end
  end
end
