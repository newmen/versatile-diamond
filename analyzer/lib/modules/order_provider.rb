module VersatileDiamond
  module Modules

    # Provides methods for lists comparing
    module OrderProvider
    private

      # Orders two object by method which typize each object. Objects with same type
      # will be combined in result ordered sequence.
      #
      # @param [Object] a is first object
      # @param [Object] b is second object
      # @param [Symbol | Class] method_name_or_class the name of boolean method for
      #   typing each object or class kind of should be the last object
      # @yeild if passed the calling when objects has same types
      # @return [Integer] the order of objects
      def typed_order(a, b, method_name_or_class, &block)
        va, vb = [a, b].map do |x|
          if method_name_or_class.is_a?(Symbol)
            x.send(method_name_or_class)
          elsif method_name_or_class.is_a?(Class)
            x.is_a?(method_name_or_class)
          else
            fail 'Wrong type of "method_name_or_class" variable'
          end
        end

        if !va && vb
          -1
        elsif va && !vb
          1
        else
          block_given? ? block.call : 0
        end
      end

      # Compares two objects by method name and next methods chain or detect block
      # @param [Object] a is first object
      # @param [Object] b is second object
      # @param [Array] methods_chain by which value for comparison will gotten
      # @option [Proc] :first_method_block the block which will be applied to call of
      #   first method in chain
      # @yield if passed then calling when objects is same by used method
      # @return [Integer] the order of objects
      def order(a, b, *methods_chain, first_method_block: nil, &block)
        va = value_by_chain(a, methods_chain.dup, first_method_block)
        vb = value_by_chain(b, methods_chain.dup, first_method_block)

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
