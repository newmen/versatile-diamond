module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The base class for algorithm builder units
        # @abstract
        class BaseCheckerUnit < GenerableUnit
          include Mcs::SpecsAtomsComparator
          include Modules::ListsComparer
          include Modules::ProcsReducer
          include NeighboursCppExpressions

          # Also stores the cheking context and creates the cache variables
          # @param [EngineCode] generator the major code generator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [Specie | TypicalReaction LateralChunks] context in which the
          #   algorithm builds
          def initialize(generator, namer, context)
            super(generator, namer)
            @context = context

            @_uniq_species, @_uniq_atoms, @_symmetric_atoms = nil
          end

        protected

          # Gets the list of unique species
          # @return [Array] the list of unique species
          def uniq_species
            @_uniq_species ||= species.uniq
          end

          # Gets the list of unique atoms
          # @return [Array] the list of unique atoms
          def uniq_atoms
            @_uniq_atoms ||= atoms.uniq
          end

          # Checks that just one unique specie uses in current unit
          # @return [Boolean] is whole unit or not
          def whole?
            uniq_species.all_equal?
          end

          # Checks that just one unique atom uses in current unit
          # @return [Boolean] is mono unit or not
          def mono?
            uniq_atoms.all_equal?
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

          attr_reader :context

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_name_of(obj)
            name_of(obj) || 'undef'
          end

          # Gets just symmetric atoms
          # @param [Array] the list of symmetric atoms
          def symmetric_atoms
            @_symmetric_atoms ||= symmetric_species_with_atoms.map(&:last)
          end

          # Checks that state of passed unit is same as current state
          # @param [MonoUnit] other comparing unit
          # @return [Boolean] are equal states of units or not
          def same_inner_state?(other)
            lists_are_identical?(specs_atoms, other.specs_atoms, &:same_sa?)
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
