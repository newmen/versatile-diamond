module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Provides addiitonal methods for reaction algorithms
        class TargetsDictionary < VarsDictionary
          # @param [TypicalReaction] reaction
          def initialize(reaction)
            super()
            @reaction = reaction
          end

          # @return [Core::This]
          def make_this
            var_of(:this) || store!(Core::This[:this, @reaction.class_name])
          end

          # @param [Object] specie_s
          def make_target_s(specie_s)
            if all_defined_vars.any?(&:call?)
              raise NameError, 'Targets already defined'
            elsif array?(specie_s)
              many_targets(specie_s)
            else
              one_target(fix_instance(specie_s))
            end
          end

          # @return [Array]
          # @override
          def defined_vars
            defined_exprs = super
            if defined_exprs.any?(&:call?)
              vars = defined_exprs.reject(&:call?)
              var_of(:this) ? vars : vars + [make_this]
            else
              defined_exprs
            end
          end

        private

          # @param [Instances::SpecieInstance] specie call of which will be maked
          # @param [Array] args
          # @return [TargetCall]
          def one_target(specie, *args)
            store!(TargetCall[specie, *args])
          end

          # @param [Array] species
          # @return [Array]
          def many_targets(species)
            species.map.with_index do |specie, index|
              one_target(specie, Core::Constant[index])
            end
          end
        end

      end
    end
  end
end
