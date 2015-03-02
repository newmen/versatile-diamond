module VersatileDiamond
  module Organizers

    # Represent the table of dynamic programming for organization of dependencies
    # between all wrapped base species
    class BaseSpeciesTable < DpTable
    private

      # Gets the empty residual for passed base specie
      # @param [DependentBaseSpec] base_spec for which the empty residual will be got
      # @return [SpecResidual] the empty residual for passed base specie
      def empty_residual(base_spec)
        SpecResidual.empty(base_spec)
      end
    end

  end
end
