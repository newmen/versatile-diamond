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
      # @return [Array] the pair of spec and atom
      def swap(spec_atom, from, to)
        return spec_atom unless spec_atom[0] == from

        if !from.specific_atoms.empty? && to.specific_atoms.empty?
          raise ArgumentError, 'Swapping specific spec loses specification'
        end

        mirror = Mcs::SpeciesComparator.make_mirror(from, to)

        if mirror.size < to.links.size
          raise ArgumentError, 'Intersection less than swapped specs'
        end

        [to, mirror[spec_atom[1]]]
      end

      # Swaps atoms in passed spec_atom instance
      # @param [Array] spec_atom the instance with spec and atom which will be changed
      #   if spec is equal to passed spec and atom is equal to passed "from" instance
      # @param [SpecificSpec] spec the specific spec the atom of which will be swapped
      # @param [Atom] from the used atom
      # @param [Atom] to the new atom
      def swap_only_atoms(spec_atom, spec, from, to)
        if spec_atom[0] == spec && spec_atom[1] == from
          [spec, to]
        else
          spec_atom
        end
      end
    end

  end
end
