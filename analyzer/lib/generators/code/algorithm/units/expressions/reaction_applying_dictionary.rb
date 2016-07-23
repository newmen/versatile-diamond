module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Provides addiitonal methods for reaction applying expression instances
        class ReactionApplyingDictionary < TargetsDictionary
          # @return [AtomsBuilderVariable]
          def make_atoms_builder
            var_of(:atoms_builder) || store!(AtomsBuilderVariable[:atoms_builder])
          end
        end

      end
    end
  end
end
