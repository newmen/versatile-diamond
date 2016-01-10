module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The class for reaction find algorithm builder units with many species
        class ManyReactantsUnit < BaseManyReactantsUnit
          include ReactantUnitBehavior

          # Initializes the unit of code builder algorithm
          # @param [Array] args of base class constructor
          # @param [Organizers::DependentTypicalReaction] dept_reaction by which the
          #   relations between atoms will be checked
          def initialize(*args, dept_reaction)
            super(*args)
            @dept_reaction = dept_reaction
          end

          def inspect
            "MRSU:(#{inspect_species_atoms_names}])"
          end

        private

          attr_reader :dept_reaction

        end

      end
    end
  end
end
