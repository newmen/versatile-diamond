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
          # @param [Units::BaseUnit] curr_unit from which relations will be checked
          # @param [Units::BaseUnit] nbrs_unit to which relations will be checked
          # @return [Proc] lazy calling for check relations unit method
          def relations_proc(curr_unit, nbrs_unit, rel_params)
            -> &block { curr_unit.check_relations(nbrs_unit, rel_params, &block) }
          end
        end

      end
    end
  end
end
