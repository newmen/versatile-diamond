module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Decorates unit for bulding lateral dependent code on context
        class ContextLateralUnit < ContextReactionUnit
          # @param [Expressions::VarsDictionary] _
          # @param [BasePureUnitsFactory] _
          # @param [BaseContextProvider] _
          # @param [BasePureUnit] _
          def initialize(*)
            super
            @_action_unit = nil
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_existence(&block)
            if action_unit.species.one?
              super { action_unit.define_undefined_atoms(&block) }
            else
              action_unit.define_undefined_atoms { super(&block) }
            end
          end

        protected

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_sidepieces(&block)
            call_procs(sidepieces.flat_map(&method(:check_sidepiece_procs)), &block)
          end

        private

          # @return [BasePureUnit]
          def action_unit
            @_action_unit ||= pure_factory.unit(context.action_nodes)
          end

          # @return [Array]
          def sidepieces
            species.select(&:proxy?)
          end

          # @param [ContextLateralUnit] nbr
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # @override
          def check_avail_species_in(nbr, &block)
            super(nbr) do
              nbr.check_sidepieces(&block)
            end
          end

          # @param [Instances::OtherSideSpecie] specie
          # @return [Array]
          def check_sidepiece_procs(specie)
            [different_vars_proc(specie), same_vars_proc(specie)]
          end

          # @param [Class] cond_expr_class
          # @param [Instances::OtherSideSpecie] specie
          # @param [Array] other_vars
          # @return [Proc]
          def check_sidepiece_proc(cond_expr_class, specie, other_vars)
            vars_pairs = reverse_vars_pairs(specie, other_vars)
            clean_pairs = vars_pairs.reject { |s, o| s.code > o.code }
            -> &block do
              if clean_pairs.empty?
                block.call
              else
                cond_expr_class[clean_pairs, block.call]
              end
            end
          end

          # @param [Instances::OtherSideSpecie] specie
          # @return [Proc]
          def same_vars_proc(specie)
            vars = dict.same_vars(specie)
            check_sidepiece_proc(Expressions::EqualsCondition, specie, vars)
          end

          # @param [Instances::OtherSideSpecie] specie
          # @return [Proc]
          def different_vars_proc(specie)
            vars = dict.different_vars(specie)
            check_sidepiece_proc(Expressions::NotEqualsCondition, specie, vars)
          end

          # @param [Array] other_vars
          # @return [Array]
          def reverse_vars_pairs(specie, other_vars)
            var = dict.var_of(specie)
            other_vars.zip([var].cycle)
          end
        end

      end
    end
  end
end
