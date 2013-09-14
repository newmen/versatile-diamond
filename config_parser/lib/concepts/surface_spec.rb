module VersatileDiamond
  module Concepts

    # Represents surface structure
    class SurfaceSpec < Spec

      # Exception for case when linking atoms do not have a crystal lattice
      class UnspecifiedAtoms < Exception; end

      # Returns that spec is not gas
      # @return [Boolean] gas or not
      def is_gas?
        false
      end

    private

      # Links together atoms of surface spec. Surface spec must have at least
      # one atom belonging to the lattice. Obtaining the inverse relation
      # between linking atoms is occured by the crystal lattice.
      #
      # @param [Array] atoms the array of two linking atoms
      # @param [Bond] instance the instance of relation
      # @raise [UnspecifiedAtoms] unless at least one atom belonging to lattice
      # @raise [Lattices::Base::WrongRelation] if used relation instance is
      #   wrong for current lattice
      def link_together(*atoms, instance)
        has_lattice = -> atom { atom.lattice }
        raise UnspecifiedAtoms unless atoms.any?(&has_lattice)

        index = atoms.index(&has_lattice)
        first = atoms.delete_at(index)
        second = atoms.pop
        
        opposit_instance =
          first.lattice.opposite_edge(second.lattice, instance)

        link_with_each_other(first, second, instance, opposit_instance)
        find_positions
      end

      def find_positions
        atom_instances.combination(2).each do |first, second|
          next if related?(first, second)

          positions = first.lattice.positions_to(links, first, second)
          next unless positions

          link_with_each_other(first, second, *positions)
        end
      end

      def related?(first, second)
        links[first].find { |atom, _| atom == second }
      end
    end

  end
end
