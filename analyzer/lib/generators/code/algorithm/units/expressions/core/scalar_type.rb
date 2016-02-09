module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of class types
        class ScalarType < Constant
          class << self
            # @param [Object] name
            # @return [Type]
            def [](name)
              if_validated(name) { super }
            end

          private

            # @param [String] name
            # @yield
            def if_validated(name, &block)
              if !str?(name)
                arg_err!("Wrong type name #{name.inspect}")
              elsif empty?(name)
                arg_err!('Type cannot be empty')
              else
                block.call
              end
            end
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

          # @return [Type]
          def ptr
            before = ptr? ? value : "#{value} "
            ScalarType["#{before}*"]
          end
        end

      end
    end
  end
end
