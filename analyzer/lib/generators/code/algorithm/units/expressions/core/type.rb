module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of types
        class Type < Constant

          # @return [Constant]
          def def_type
            class? ? append_star(name) : name
          end

          # @return [Constant]
          def arg_type
            append_star(def_type)
          end

          # @param [Expression] expr
          # @return [Statement] the name with reference to member
          def member_ref(expr)
            if class?
              OpRef[OpNs[self, expr]]
            else
              raise 'Cannot get the class member not from class type'
            end
          end

        private

          # @return [Boolean] class type names any time are classified
          def class?
            !!name.match(/^[A-Z]/)
          end

          def append_star(expr)
            Constant["#{expr.code} *"]
          end
        end

      end
    end
  end
end
