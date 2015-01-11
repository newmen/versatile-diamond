module VersatileDiamond
  using Patches::RichArray

  module Concepts

    # Represents surface structure
    class SurfaceSpec < Spec
      include Lattices::BasicRelations
      include SurfaceLinker

      # Returns that spec is not gas
      # @return [Boolean] gas or not
      def gas?
        false
      end

      # Finds position relation between two atoms, where first atom belongs to
      # largest structure (specie) and relation has direction from atom of
      # first spec to atom of second spec
      #
      # @param [Atom] first the first atom
      # @param [Atom] second the second atom
      # @return [Position] the position relation or nil
      def position_between(first, second)
        relation = relation_between(first, second)
        relation && relation.belongs_to_crystal? && relation.make_position
      end

    protected

      # After linking finds position by relation rules from crystal lattice
      # @param [Array] args the argumens of super method
      # @raise [Position::UnspecifiedAtoms] unless at least one atom
      #   belonging to lattice
      # @override
      def link_together(*atoms, instance)
        if instance != undirected_bond
          raise Position::UnspecifiedAtoms unless at_least_one_latticed?(atoms)
          super(*sort(atoms), instance)
          find_positions
        else
          raise Position::UnspecifiedAtoms unless at_least_one_latticed?(@atoms.values)
          super(*atoms, instance)
        end
      end

    private

      # Gets opposite relation between first and second atoms for passed
      # relation instance
      #
      # @param [Atom] first the first of two linking atoms
      # @param [Atom] second the second of two linking atoms
      # @param [Bond] relation the instance of relation
      # @raise [Lattices::Base::UndefinedRelation] when passed relation is
      #   undefined
      # @return [Bond] the opposite relation
      def opposite_relation(first, second, relation)
        target_lattice = first.lattice || second.lattice
        if target_lattice
          other_lattice = first.lattice == target_lattice ? second.lattice : nil
          target_lattice.opposite_relation(other_lattice, relation)
        else
          raise 'Wrong relation' unless relation == undirected_bond
          relation
        end
      end

      # Finds and store positions between transitive bonded atoms
      def find_positions
        atom_instances.combination(2).each do |atoms|
          next if !at_least_one_latticed?(atoms) || relation_between(*atoms)
          first, second = sort(atoms)

          positions =
            first.lattice.positions_between(first, second, links)
          next unless positions

          link_with_other(first, second, *positions)
        end
      end

      # Checks that at least one atoms belongs to lattice
      # @param [Array] atoms the array of atoms
      # @return [Boolean] has latticed atom or not
      def at_least_one_latticed?(atoms)
        atoms.any?(&:lattice)
      end

      # Sorts atoms by having crystall lattice
      # @param [Array] atoms the array of atoms
      # @return [Array] the sorted atoms array
      def sort(atoms)
        atoms_dup = atoms.dup
        first = atoms_dup.delete_one(&:lattice)
        [first, atoms_dup.pop]
      end
    end

  end
end
