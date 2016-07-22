module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Provides addiitonal methods for lateral expression instances
        class LateralExprsDictionary < TargetsDictionary
          # @return [ChunksList]
          def make_chunks_next_item
            make_chunks_with(:chunks_item, index: Core::OpRInc[make_iterator(:index)])
          end

          # @return [ChunksList]
          def make_chunks_first_item
            make_chunks_with(:first_chunk, index: Core::Constant[0])
          end

          # @return [ChunksList]
          def make_chunks_list
            make_chunks_with(:chunks_list)
          end

          # @return [Core::Variable]
          def make_chunks_counter
            num_var = var_of(:num)
            chunks_list = var_of(:chunks_list)
            name = SpeciesReaction::COUNTER_VAR_NAME
            value = Core::FunctionCall['countReactions', chunks_list, num_var].freeze
            store!(Core::Variable[:chunks_counter, COUNTER_TYPE, name, value: value])
          end

          # Does not store the result in internal state
          # @param [String] index
          # @return [Core::Variable]
          def counter_item(index)
            type = ChunksCounterType::VALUE_TYPE
            name = SpeciesReaction::COUNTER_VAR_NAME
            Core::Variable[:counter_item, type, name, index: Core::Constant[index]]
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

          CHUNKS_TYPE = ChunksType[].ptr.freeze
          COUNTER_TYPE = ChunksCounterType[].freeze

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

          # @param [Symbol] instance
          # @param [Core::Expression] index
          # @return [ChunksList]
          def make_chunks_with(instance, index: nil)
            name = SpeciesReaction::LATERAL_CHUNKS_NAME
            store!(ChunksList[instance, CHUNKS_TYPE, name, index: index])
          end
        end

      end
    end
  end
end
