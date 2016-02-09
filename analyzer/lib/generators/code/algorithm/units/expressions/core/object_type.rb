module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of class types
        class ObjectType < ScalarType
          class << self
          private

            # @override
            def if_validated(name, &block)
              super do
                if class?(name)
                  block.call
                else
                  arg_err!('Class type should be classified')
                end
              end
            end

            # @param [String] name
            # @return [Boolean] class type names any time are classified
            def class?(name)
              name =~ /^[A-Z]/
            end
          end

          # Checks that current type is scalar pointer
          # @return [Boolean]
          def scalar?
            false
          end

          # @param [FunctionCall] expr
          # @return [OpRef] the name of type with reference to member
          def member_ref(expr)
            OpRef[OpNs[self, expr]]
          end
        end

      end
    end
  end
end
