module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The base class for algorithm builder units
        # @abstract
        class BaseCheckerUnit < GenerableUnit
          include Mcs::SpecsAtomsComparator
          include Modules::ListsComparer
          include NeighboursCppExpressions

          # Also creates the cache variables
          def initialize(*)
            super
            @_uniq_atoms = nil
          end

        protected

          # Gets the list of unique atoms
          # @return [Array] the list of unique atoms
          def uniq_atoms
            @_uniq_atoms ||= atoms.uniq
          end

          # Checks that state of passed unit is same as current state
          # @param [BaseCheckerUnit] other comparing unit
          # @return [Boolean] are equal states units or not
          def same_state?(other)
            self.class == other.class && same_inner_state?(other)
          end

          # Checks that passed unit uses same relations as current
          # @param [BaseCheckerUnit] other comparing unit
          # @return [Boolean] are equal relations of units or not
          def same_relations?(other)
            self.class == other.class && same_using_relations?(other)
          end

        private

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_name_of(obj)
            name_of(obj) || 'undef'
          end

          # Checks that passed unit uses same relations as current
          # @param [MonoUnit] other comparing unit
          # @return [Boolean] are equal relations of units or not
          def same_using_relations?(other)
            lists_are_identical?(all_using_relations, other.all_using_relations, &:==)
          end
        end

      end
    end
  end
end
