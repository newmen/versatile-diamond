module VersatileDiamond
  module Concepts

    # Provides method for swapping spec and their atom
    module SpecAtomSwapper
    private

      # Swaps spec and their atom from some to some
      # @param [Array] spec_atom the array where first element is specific spec
      #   and second element id their atom
      # @param [SpecificSpec] from the spec from which need to swap
      # @param [SpecificSpec] to the spec to which need to swap
      def swap(spec_atom, from, to)
        return unless spec_atom[0] == from

        if !from.specific_atoms.empty? && to.specific_atoms.empty?
          raise ArgumentError, 'Swapping specific spec loses specification'
        end

        mirror = Mcs::SpeciesComparator.make_mirror(from, to)

        if mirror.size < to.links.size
          raise ArgumentError, 'Intersection less than swapped specs'
        end

        spec_atom[0] = to
        spec_atom[1] = mirror[spec_atom[1]]
      end

    end

  end
end
