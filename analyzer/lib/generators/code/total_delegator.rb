module VersatileDiamond
  module Generators
    module Code

      # Provides delegator behavior
      module TotalDelegator

        # Describe method missing for some target that name presented as symbol
        # @param [Symbo] target_symbol the target that will recive all missed calls
        def deligate_to(target_symbol)
          # Deligates all missed method calls to target
          # @param [Array] args the arguments of missed method
          define_method(:method_missing) do |*args, &block|
            target = target_symbol.to_s =~ /^@/ ?
              instance_variable_get(target_symbol) :
              send(target_symbol)

            target.public_send(*args, &block)
          end
        end
      end

    end
  end
end
