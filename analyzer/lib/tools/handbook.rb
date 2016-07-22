module VersatileDiamond
  module Tools

    # Provides useful methods for RSpec
    module Handbook
      # Hook for including case
      # @param [Module] base the module which uses current module
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Resets internal cache for RSpec
        def reset!
          @@__handbook.clear
          @@__holder = nil
        end

      private

        # Provides a special action for defining memoised instance methods
        # @param [Symbol] name the name of defining method
        # @yield the body of method
        def set(name, &block)
          __extend_scope(name, &__scope_cache_proc(name, &block))

          __sh = __scope_holder # closure
          define_method(name) do
            @__evaluator ||= __sh.new
            @__evaluator.public_send(name)
          end
        end

        # Stubs and caches the entities which are in RSpec namespace
        # @param [Symbol] name the name of entity
        # @yield the value of entity
        def stub(name, &block)
          define_method(name, &__scope_cache_proc(name, &block))

          __hb = __handbook_cache # closure
          __extend_scope(name) { __hb[name] }
        end

        # @return [Hash]
        def __handbook_cache
          @@__handbook ||= {}
        end

        # @return [Class]
        def __scope_holder
          @@__holder ||= Class.new
        end

        # Adds the new function to scope holder
        def __extend_scope(name, &block)
          __scope_holder.send(:define_method, name, &block)
        end

        # @return [Proc]
        def __scope_cache_proc(name, &block)
          __hb = __handbook_cache # closure
          -> { __hb[name] ||= instance_eval(&block) }
        end
      end
    end

  end
end
