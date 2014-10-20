module VersatileDiamond
  module Modules

    # Provides methods for lists comparing
    module OrderProvider
    private

      # Compares two objects by method name and next methods chain or detect block
      # @param [Object] a is first object
      # @param [Object] b is second object
      # @param [Array] methods_chain by which value for comparison will gotten;
      #   the last value of it list (not first) interpret as block which will be
      #   applied to call of first method in chain
      # @yield if passed then calling when objects is same by used method
      # @return [Integer] the order of objects
      def order(a, b, *methods_chain, &block)
        if methods_chain.size > 1
          detect_block = methods_chain.last
          correct_chain = methods_chain[0..-2]
        else
          detect_block = nil
          correct_chain = methods_chain
        end

        va = value_by_chain(a, correct_chain.dup, detect_block)
        vb = value_by_chain(b, correct_chain.dup, detect_block)

        if va == vb
          block_given? ? block.call : 0
        else
          va <=> vb
        end
      end

      # Recursive get the value of target while methods chain isn't empty
      # @param [Object] target for which will be applied first method in methods chain
      # @param [Array] methods_chain the list of methods which will be recursive
      #   applied to each next value
      # @param [Proc] block will be passed to first method in chain
      # @return [Object] the final value
      def value_by_chain(target, methods_chain, block = nil)
        method_name = methods_chain.shift
        if method_name
          value = block ? target.send(method_name, &block) : target.send(method_name)
          value_by_chain(value, methods_chain)
        else
          target
        end
      end
    end

  end
end
