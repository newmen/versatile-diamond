module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Provides addiitonal methods for lateral expression instances
        class LateralExprsDictionary < VarsDictionary
          # @param [Array] action_nodes
          def initialize(action_nodes)
            super()
            @action_atoms = action_nodes.map(&:atom)
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

        private

          # @return [Array]
          def action_vars
            aa_arr = var_of(@action_atoms)
            (aa_arr ? [aa_arr] : []) + @action_atoms.map(&method(:var_of)).compact
          end

          # @return [Array]
          def action_used_names
            action_vars.map(&:code)
          end

          # @return [Array]
          def action_next_names
            action_used_names.select { |name| name =~ /\d+$/ }
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
            fixed_state = state.dup
            atoms_vars_hash = action_vars.map { |v| [key_of(v.instance), [v]] }.to_h
            fixed_state[:vars] = fixed_state[:vars].merge(atoms_vars_hash)
            fixed_state[:used_names] += action_used_names
            fixed_state[:next_names] += action_next_names

            super(fixed_state)
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
