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

            affixes_groups = lateral_chunks.affixes_nums.to_a
            singulars = split_chunks_with(affixes_groups, :select)
            multiples = split_chunks_with(affixes_groups, :reject)
            @limited_group = singulars + multiples.select { |n, _| n == 1 }
            @coupled_group = multiples.reject { |n, _| n == 1 }
            @affixes_num = affixes_groups.size
          end

          # @return [Units::LateralSelectorScopeUnit]
          def scope_unit
            Units::LateralSelectorScopeUnit.new(@dict)
          end

          # @return [Units::LateralSelectorLimitedUnit]
          def limited_unit
            Units::LateralSelectorLimitedUnit.new(@dict, @limited_group)
          end

          # @return [Units::LateralSelectorCoupledUnit]
          def coupled_unit
            Units::LateralSelectorCoupledUnit.new(@generator, @dict, @coupled_group)
          end

          # @return [Units::LateralSelectorFooterUnit]
          def footer_unit
            Units::LateralSelectorFooterUnit.new(@affixes_num)
          end

        private

          # Selects reactions from affixes groups by passed method
          # @param [Array] affixes_groups
          # @param [Symbol] filter_name the name of method by which the selection will
          #   be done
          # @return [Array] the list of selected groups
          def split_chunks_with(affixes_groups, filter_name)
            affixes_groups.public_send(filter_name) { |_, reactions| reactions.one? }
          end
        end

      end
    end
  end
end
