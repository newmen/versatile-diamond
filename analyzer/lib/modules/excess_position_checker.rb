module VersatileDiamond
  module Modules

    # Provides methods for cleaning links
    module ExcessPositionChecker
    private

      # Checks that passed relation is position and that it is excess
      # @param [Concepts::Bond | Concepts::NoBond] relation which will checked
      # @param [Object] first checking vertex
      # @param [Object] second checking vertex
      # @return [Boolean] is excess position or not
      def excess_position?(relation, first, second)
        relation.relation? && !relation.bond? &&
          excess_position_between?(first, second)
      end

      # Checks that current instance have excess position between passed atoms
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   first checking atom
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   second checking atom
      # @return [Boolean] has excess poosition or not
      def excess_position_between?(first, second)
        crystal = check_latticed_atom(first, second).lattice.instance
        !!crystal.position_between(first, second, original_links)
      end

      # Selects latticed atom from passed pair
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   first checking atom
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   second checking atom
      # @return [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   the atom with lattice
      def check_latticed_atom(first, second)
        if first.lattice == second.lattice
          first
        else
          raise 'Wrong position between atoms that belongs to different lattices'
        end
      end
    end

  end
end
