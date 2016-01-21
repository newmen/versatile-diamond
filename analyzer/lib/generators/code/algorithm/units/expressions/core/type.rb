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
                raise "Wrong type name #{name.inspect}"
              elsif empty?(name)
                raise 'Type cannot contain be empty'
              elsif !class?(name)
                raise 'Class type should be classified'
              else
                new(name)
              end
            end

          private

            # @param [String] name
            # @return [Boolean] class type names any time are classified
            def class?(name)
              name =~ /^[A-Z]/
            end
          end

          # @return [Type]
          def ptr
            correct_value = code
            correct_value += ' ' unless correct_value =~ /(\*)$/
            self.class["#{correct_value}*"]
          end

          # @param [Constant] expr
          # @return [OpRef] the name of type with reference to member
          def member_ref(expr)
            OpRef[OpNs[self, expr]]
          end
        end

      end
    end
  end
end
