module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides logic for units which uses when reaction find algorithm builds
        module ReactantUnitBehavior
          include Algorithm::ReactantUnitCommonBehavior
          include Algorithm::SpecificSpecDefiner

        private

          # Gets the instance which can check the relation between units
          # @return [Organizers::DependentTypicalReaction] the target reaction
          def relations_checker
            dept_reaction
          end
        end

      end
    end
  end
end
