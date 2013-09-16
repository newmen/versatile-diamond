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
        raise UnspecifiedAtoms unless at_least_one_lattice(atoms)
        first, second = sort(atoms)

        opposit_instance =
          first.lattice.opposite_relation(second.lattice, instance)

        raise Position::Duplicate, instance if instance.class == Position &&
          has_positions?(first, second, instance, opposit_instance)

        link_with_each_other(first, second, instance, opposit_instance)
        find_positions
      end

      # Finds and store positions between transitive bonded atoms
      def find_positions
        atom_instances.combination(2).each do |atoms|
          next if !at_least_one_lattice(atoms) || related?(*atoms)
          first, second = sort(atoms)

          many_positions =
            first.lattice.positions_between(first, second, links)
          next if many_positions.empty?

          many_positions.each do |positions|
            link_with_each_other(first, second, *positions)
          end
        end
      end

      # Checks that atom belongs to crystal lattice
      # @param [Atom] atom the checking atom
      # @return [Boolean] belongs or not
      def has_lattice?(atom)
        !!atom.lattice
      end

      # Checks that at least one atoms belongs to lattice
      # @param [Array] atoms the array of atoms
      # @return [Boolean] has latticed atom or not
      def at_least_one_lattice(atoms)
        atoms.any?(&method(:has_lattice?))
      end

      # Sorts atoms by having crystall lattice
      # @param [Array] atoms the array of atoms
      # @return [Array] the sorted atoms array
      def sort(atoms)
        index = atoms.index(&method(:has_lattice?))
        first = atoms.delete_at(index)
        [first, atoms.pop]
      end

      # Checks that atoms is related
      # @param [Atom] first the first atom
      # @param [Atom] second the second atom
      # @return [Boolean] related or not
      # TODO: move to super?
      def related?(first, second)
        !!links[first].find { |atom, _| atom == second }
      end

      # If so, must have relations in both directions
      # @param [Atom] first the first atom
      # @param [Atom] second the second atom
      # @param [Array] positions the array with two positions
      # @return [Boolean] has or not
      def has_positions?(first, second, *positions)
        a = has_position?(first, second, positions[0])
        b = has_position?(second, first, positions[1])

        if a && b
          true
        elsif a || b
          raise "Checking positions ERROR"
        else
          false
        end
      end

      # Check availability of passed position between atoms
      # @param [Atom] first the first atom
      # @param [Atom] second the second atom
      # @param [Bond] position the relation from first atom to second atom
      # @return [Boolean] has or not
      def has_position?(first, second, position)
        !!links[first].find { |atom, link| atom == second && link == position }
      end
    end

  end
end
