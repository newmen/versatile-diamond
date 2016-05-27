module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Provides addiitonal methods for lateral expression instances
        class LateralExprsDictionary < VarsDictionary
          # @param [TypicalReaction] reaction
          def initialize(reaction)
            super()
            @reaction = reaction
            @this = nil
          end

          # @return [Core::Variable]
          def make_this
            @this ||= store!(Core::This[:this, @reaction.class_name])
          end

          # @return [Core::Variable]
          def make_chunks_next_item
            name = "#{SpeciesReaction::LATERAL_CHUNKS_NAME}"
            index = OpRInc[make_iterator(:index)]
            store!(ChunksList[:chunks, CHUNKS_TYPE, name, index: index])
          end

          # @param [Object] specie_s
          def make_target_s(specie_s)
            if array?(specie_s)
              many_targets(specie_s)
            else
              one_target(fix_instance(specie_s))
            end
          end

          # @param [Instances::OtherSideSpecie] specie
          # @return [Array]
          def same_vars(specie)
            if specie.proxy?
              original = specie.original
              sames = @same_sidepieces.select { |o, _| o == original }.map(&:last)
              sames.reject { |s| s == specie }.map(&method(:var_of))
            else
              raise ArgumentError, 'Same others can be gotten just from sidepiece'
            end
          end

          # @param [Instances::OtherSideSpecie] specie
          # @return [Array]
          def different_vars(specie)
            if specie.proxy?
              original = specie.original
              super_original = original.original
              sames = @same_sidepieces.select { |o, _| o.original == super_original }
              diffs = sames.reject { |o, s| o == original || s == specie }.map(&:last)
              diffs.map(&method(:var_of))
            else
              raise ArgumentError, 'Different others can be gotten just from sidepiece'
            end
          end

          # @return [Array]
          # @override
          def defined_vars
            defined_exprs = super
            if defined_exprs.any?(&:call?)
              vars = defined_exprs.reject(&:call?)
              this_defined? ? vars : vars + [make_this]
            else
              defined_exprs
            end
          end

        private

          CHUNKS_TYPE = ChunksType[].ptr.freeze

          # @return [Boolean]
          def this_defined?
            !!@this
          end

          # @override
          def reset!
            super
            @same_sidepieces = []
          end

          # @return [Hash]
          # @override
          def current_state
            super.merge({ same_sidepieces: @same_sidepieces.dup })
          end

          # @param [Hash] state
          # @override
          def restore!(state)
            super
            @same_sidepieces = state[:same_sidepieces].dup
          end

          # @param [Core::Variable]
          # @return [Core::Variable]
          # @override
          def store!(var)
            if !var.collection? && var.proxy?
              specie = var.instance
              @same_sidepieces << [specie.original, specie]
            end
            super
          end

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
