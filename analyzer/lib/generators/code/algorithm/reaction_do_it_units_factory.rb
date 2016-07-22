module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates units for applying reaction algorithm
        class ReactionDoItUnitsFactory
          # @param [Changes] changes
          def initialize(changes)
            @changes = changes

            reaction = changes.reaction
            @dict = Units::Expressions::ReactionApplyingDictionary.new(reaction)
            @context =
              Units::ChangesContextProvider.new(reaction, changes.main, changes.full)
          end

          # @return [Units::TargetSourcesUnit]
          def sources_unit
            Units::TargetSourcesUnit.new(@dict, @changes.main + @context.significant)
          end

          # @return [Units::TargetSourcesUnit]
          def changes_unit
            Units::AtomsChangeUnit.new(@dict, @context, @changes.main)
          end

          # @return [Units::ApplyingCloseUnit]
          def close_unit
            Units::ApplyingCloseUnit.new(@dict, @changes.main)
          end
        end

      end
    end
  end
end
