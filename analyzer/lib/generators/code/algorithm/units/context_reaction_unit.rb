module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Decorates unit for bulding reaction dependent code on context
        class ContextReactionUnit < ContextBaseUnit
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_existence(&block)
            check_symmetries(&block)
          end

        protected

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def select_specie_definition(&block)
            check_many_undefined_species(&block)
          end

        private

          # @return [Array]
          def splitten_inner_units
            unit.complete_inner_units
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_close_atoms(&block)
            if all_defined?(species) && context.relations_from?(nodes)
              unit.define_undefined_atoms(&block)
            else
              block.call
            end
          end

          # @param [Array] checking_nodes
          # @return [Boolean]
          def same_specie_in?(checking_nodes)
            checking_nodes.map(&:uniq_specie).uniq.size < 2
          end

          # @param [Array] _
          # @return [Boolean]
          def checkable_neighbour_species?(*)
            true
          end
        end

      end
    end
  end
end
