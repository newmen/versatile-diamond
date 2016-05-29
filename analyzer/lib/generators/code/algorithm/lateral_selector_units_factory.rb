module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates units for lateral selector algorithm
        class LateralSelectorUnitsFactory
          # @param [EngineCode] generator of engine code
          # @param [LateralChunks] lateral_chunks
          def initialize(generator, lateral_chunks)
            @generator = generator
            @dict =
              Units::Expressions::LateralExprsDictionary.new(lateral_chunks.reaction)
            @affixes_groups = lateral_chunks.affixes_nums.to_a
          end

          # @return [Units::LateralSelectorScopeUnit]
          def scope_unit
            Units::LateralSelectorScopeUnit.new(@dict, minimal_chunks_number)
          end

          # @return [Units::LateralSelectorLimitedUnit]
          def limited_unit
            Units::LateralSelectorLimitedUnit.new(@dict, limited_group)
          end

          # @return [Units::LateralSelectorCoupledUnit]
          def coupled_unit
            Units::LateralSelectorCoupledUnit.new(@generator, @dict, coupled_group)
          end

          # @return [Units::LateralSelectorFooterUnit]
          def footer_unit
            Units::LateralSelectorFooterUnit.new
          end

        private

          # @return [Integer]
          def minimal_chunks_number
            @affixes_groups.first.first
          end

          # @return [Array]
          def limited_group
            split_chunks_with(:select)
          end

          # @return [Array]
          def coupled_group
            split_chunks_with(:reject)
          end

          # Selects reactions from affixes groups by passed method
          # @param [Symbol] filter_name the name of method by which the selection will
          #   be done
          # @return [Array] the list of selected groups
          def split_chunks_with(filter_name)
            @affixes_groups.public_send(filter_name) { |_, reactions| reactions.one? }
          end
        end

      end
    end
  end
end
