module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain base logic for building find algorithms
        # @abstract
        class BaseFindAlgorithmBuilder
          include Modules::ProcsReducer

        private

          # Wraps calling of checking relations between generation units to lambda
          # @param [Units::BaseContextUnit] unit from which relations will be checked
          # @param [Units::BaseContextUnit] nbr to which relations will be checked
          # @return [Proc] lazy calling for check relations unit method
          def relations_proc(unit, nbr)
            -> &block { unit.check_relations_with(nbr, &block) }
          end
        end

      end
    end
  end
end
