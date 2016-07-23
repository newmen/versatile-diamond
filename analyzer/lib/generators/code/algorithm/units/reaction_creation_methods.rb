module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides methods for combines statements of reaction creation
        module ReactionCreationMethods
          # @return [Expressions::Core::Statement]
          def create
            if !all_defined?(source_species)
              raise 'Not all reactants were defined'
              # Expressions::Core::Constant['NOT_ALL_REACTANTS_DEFINED']
            else
              create_from_source_species
            end
          end

        private

          # @return [Expressions::Core::Statement]
          def create_from_source_species
            redefine_source_species_as_array do
              create_with_source_species
            end
          end
        end

      end
    end
  end
end
