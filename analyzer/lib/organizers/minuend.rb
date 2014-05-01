module VersatileDiamond
  module Organizers

    # Provides method for minuend behavior
    module Minuend

      # Checks that current minuend instance is empty or not
      # @return [Boolean] empty or not
      def empty?
        links.empty?
      end

      # The number of links between atoms
      # @return [Integer] the number of links
      def links_size
        links.size
      end

      # Counts the atom reference instances
      # @return [Integer] the number of atom references
      def refs_num
        links.keys.select { |atom| atom.class == Concepts::AtomReference }.size
      end

      # Makes residual of difference between top and possible parent
      # @param [DependentBaseSpec] subtrahend the matching specie in top argument
      # @return [SpecResidual] the residual of diference between arguments or nil if
      #   it doesn't exist
      def - (subtrahend)
        intersec = first_intersec(subtrahend)
        return nil unless intersec && intersec.size == subtrahend.links_size

        minuend_atoms, _ = intersec.transpose
        mapped_set = minuend_atoms.to_set

        links_arr = purge(except(links, mapped_set))

        # replace residual atoms in minuend links to correspond atom reference to
        # atom of subtrahend spec
        mirror = Hash[intersec]
        residual_atoms = mapped_set & Set[*links_arr.map(&:first)]
        residual_atoms.map! do |atom|
          sub_atom = mirror[atom]
          ref = sub_atom.reference_to?(subtrahend.spec) ?
            sub_atom :
            reference(subtrahend, sub_atom)

          links_arr = replace(links_arr, atom, ref)
          ref
        end

        make_residual(links_arr, residual_atoms)
      end

    private

      # Finds first intersec with some spec
      # @param [DependentBaseSpec] spec the checkable specie
      # @return [Array] the array of each pair of intersection or nil if intersection
      #   have not fond
      def first_intersec(spec)
        first = Mcs::SpeciesComparator.first_general_intersec(self, spec)
        first && first.to_a
      end

      # Makes residual links without bonds between atoms from set
      # @param [Hash] links the hash of links between atoms
      # @param [Set] set the atoms, links between them will be excluded
      # @return [Array] the links without excluded bonds
      def except(links, set)
        links.map do |atom, list|
          atom_is_included = set.include?(atom)
          cut_list = list.reject do |a, _|
            atom_is_included && set.include?(a)
          end
          [atom, cut_list]
        end
      end

      # Makes new links without disconnected atoms
      # @param [Array] links the array of links between atoms (like a hash)
      # @return [Array] the links without disconnected atoms
      def purge(links)
        links.reject(&purge_condition)
      end

      # Makes atom reference to atom from subtrahend spec by residual atom and mirror
      # @param [DependentBaseSpec] subtrahend which provides original concept
      # @param [Concepts::Atom | Concepts::AtomReference] atom the reference for which
      #   will be maked
      # @return [Concepts::AtomReference] the reference to target atom
      def reference(subtrahend, atom)
        spec = subtrahend.spec
        Concepts::AtomReference.new(spec, spec.keyname(atom))
      end

      # Makes new links with replaced atom
      # @param [Array] links the array of links between atoms
      # @param [Concepts::Atom | Concepts::AtomReference] from the old atom
      # @param [Concepts::Atom | Concepts::AtomReference] to the new atom
      # @return [Array] updated array of links between atoms
      def replace(links, from, to)
        links.map do |a1, list|
          handled_list = list.map { |a2, link| [a2 == from ? to : a2, link] }
          [a1 == from ? to : a1, handled_list]
        end
      end
    end

  end
end



