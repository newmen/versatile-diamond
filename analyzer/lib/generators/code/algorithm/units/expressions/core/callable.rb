module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides call method
        module Callable
          # @param [String] method_name
          # @param [Array] args
          # @param [Hash] kwargs
          # @return [OpCall] the string with method call
          def call(method_name, *args, **kwargs)
            OpCall[self, FunctionCall[method_name, *args, **kwargs]]
          end
        end

      end
    end
  end
end
