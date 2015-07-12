module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from reactant specie
        class ReactantUnit < SingleReactantUnit
          include ReactantUnitBehavior

          # Initializes the reactant unit
          # @param [Array] args the arguments of #super method
          # @param [Organizers::DependentTypicalReaction] dept_reaction by which the
          #   relations between atoms will be checked
          def initialize(*args, dept_reaction)
            super(*args)
            @dept_reaction = dept_reaction
          end

          # Assigns the name for internal reactant specie, that it could be used when
          # the algorithm generates
          def first_assign!
            namer.assign(SpeciesReaction::ANCHOR_SPECIE_NAME, target_specie)
          end

        private

          attr_reader :dept_reaction

        end

      end
    end
  end
end
