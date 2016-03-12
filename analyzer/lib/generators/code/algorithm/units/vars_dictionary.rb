module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Collects all defined variables as references from variable instances
        class VarsDictionary
          def initialize
            clear!
          end

          def clear!
            @dict = {}
          end

          # @param [Object] instance
          # @param [Expressions::Core::Variable]
          def retain_var!(instance, variable)
            @dict[instance] = variable
          end

          # @param [Object] instance
          # @return [Expressions::Core::Variable]
          def var_of(instance)
            @dict[instance]
          end
        end

      end
    end
  end
end
