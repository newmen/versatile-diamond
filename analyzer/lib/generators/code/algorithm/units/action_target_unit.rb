module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Decorates unit for bulding wrapper of target lateral atoms definition
        class ActionTargetUnit
          extend Forwardable

          # @param [BaseContextProvider] context
          # @param [BasePureUnit] unit
          def initialize(dict, context, unit)
            @dict = dict
            @context = context
            @unit = unit
          end

          def define_scope!
            dict.make_this
            dict.make_chunks_next_item
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def predefine!(&block)
            unit.define!
            if !context.symmetric_actions?(nodes)
              unit.define_undefined_atoms(&block)
            elsif species.one?
              unit.iterate_specie_symmetries do
                unit.define_undefined_atoms(&block)
              end
            else
              unit.define_undefined_atoms do
                unit.iterate_for_loop_symmetries(&block)
              end
            end
          end

        private

          def_delegators :unit, :nodes, :species
          attr_reader :dict, :unit, :context

        end

      end
    end
  end
end
