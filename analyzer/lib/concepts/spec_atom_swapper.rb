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
        spec_atom[0] = to
        spec_atom[1] = to.atom(from.keyname(spec_atom[1]))
      end

    end

  end
end
