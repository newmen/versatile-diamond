module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides call method
        module Callable
          # @param [Array] args
          # @param [Hash] kwargs
          # @return [OpCall] the string with method call
          def call(*args, **kwargs)
            call_func_through(OpCall, *args, **kwargs)
          end

          # @param [Array] args
          # @param [Hash] kwargs
          # @return [OpDot] the string with method call
          def member(*args, **kwargs)
            call_func_through(OpDot, *args, **kwargs)
          end

        private

          # @param [Class] op_class
          # @param [Array] args
          # @param [Hash] kwargs
          # @return [OpCall] the string with method call via passed operator
          def call_func_through(op_class, *args, **kwargs)
            op_class[self, FunctionCall[*args, **kwargs]]
          end
        end

      end
    end
  end
end
