module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of class types
        class Type < Constant
          class << self
            # @param [Object] name
            # @return [Type]
            def [](name)
              if !str?(name)
                arg_err!("Wrong type name #{name.inspect}")
              elsif empty?(name)
                arg_err!('Type cannot contain be empty')
              elsif !class?(name)
                arg_err!('Class type should be classified')
              else
                super
              end
            end

          private

            # @param [String] name
            # @return [Boolean] class type names any time are classified
            def class?(name)
              name =~ /^[A-Z]/
            end
          end

          # Checks that current statement is expression
          # @return [Boolean] false
          # @override
          def expr?
            false
          end

          # Checks that current statement is type
          # @return [Boolean] true
          # @override
          def type?
            true
          end

          # @return [Type]
          def ptr
            correct_value = code
            correct_value += ' ' unless correct_value =~ /(\*)$/
            self.class["#{correct_value}*"]
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
