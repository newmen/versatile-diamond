module VersatileDiamond
  module Organizers

    # Provides additional methods for getting using atoms of dependent specie
    class DependentSpecReaction < DependentReaction
      # Gets atoms of passed spec
      # @param [DependentWrappedSpec] spec the one of reactant
      # @return [Array] the array of using atoms
      def used_atoms_of(dept_spec)
        reaction.used_atoms_of(dept_spec.spec)
      end
    end

  end
end
