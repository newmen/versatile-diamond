module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Decorates unit for bulding lateral dependent code on context
        class ContextLateralUnit < ContextReactionUnit
          def initialize(*)
            super
            @_key_atoms = nil
          end

        protected

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_sidepieces(&block)
            call_procs(sidepieces.flat_map(&method(:check_sidepiece_procs)), &block)
          end

        private

          # @return [Array]
          def key_atoms
            @_key_atoms ||= context.key_nodes.map(&:atom)
          end

          # @return [Boolean]
          def main_key?
            lists_are_identical?(atoms, key_atoms)
          end

          # @return [Boolean]
          def symmetric_key_atoms?
            lists_are_identical?(symmetric_atoms, key_atoms) &&
              !all_defined?(symmetric_atoms) # symmetries iteration is already underway
          end

          # @return [Boolean]
          def symmetric_target?
            main_key? && symmetric_key_atoms?
          end

          # @return [Boolean]
          # @override
          def symmetric?
            symmetric_target? && super
          end

          # @param [Array] checking_nodes
          # @return [Boolean]
          # @override
          def same_specie_in?(checking_nodes)
            !checking_nodes.all?(&:side?) || super(checking_nodes.map(&:original))
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
