module VersatileDiamond
  module Mcs

    # Provides method for comaring two spec-atom instances
    module SpecsAtomsComparator
      # Checks that two spec-atom instances are same
      # @param [Array] sa1 the first spec-atom instance
      # @param [Array] sa2 the second spec-atom instance
      # @return [Boolean] is same spec-atom instances or not
      def same_sa?(sa1, sa2)
        return true if sa1 == sa2
        (spec1, atom1), (spec2, atom2) = sa1, sa2
        return false unless spec1.equal?(spec2) || spec1.links.size == spec2.links.size

        insecs = SpeciesComparator.intersec(spec1, spec2, collaps_multi_bond: true)
        !insecs.empty? && insecs.first.size == spec1.links.size &&
          insecs.any? { |ic| ic.include?([atom1, atom2]) }
      end
    end

  end
end
