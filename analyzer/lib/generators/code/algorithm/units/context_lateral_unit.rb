module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Decorates unit for bulding lateral dependent code on context
        class ContextLateralUnit < ContextReactionUnit
        protected

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_sidepieces(&block)
            call_procs(sidepieces.flat_map(&method(:check_sidepiece_procs)), &block)
          end

        private

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
          # @param [Array] other_vars
          # @return [Proc]
          def check_sidepiece_proc(cond_expr_class, other_vars)
            vars_pairs = reverse_vars_pairs(other_vars)
            -> &block do
              if vars_pairs.empty?
                block.call
              else
                cond_expr_class[vars_pairs, block.call]
              end
            end
          end

          # @param [Instances::OtherSideSpecie] specie
          # @return [Proc]
          def same_vars_proc(specie)
            vars = dict.same_vars(specie)
            check_sidepiece_proc(Expressions::EqualsCondition, vars)
          end

          # @param [Instances::OtherSideSpecie] specie
          # @return [Proc]
          def different_vars_proc(specie)
            vars = dict.different_vars(specie)
            check_sidepiece_proc(Expressions::NotEqualsCondition, vars)
          end

          # @param [Array] vars
          # @return [Array]
          def reverse_vars_pairs(vars)
            var = dict.var_of(specie)
            vars.zip([var].cycle).map(&:reverse)
          end
        end

      end
    end
  end
end
