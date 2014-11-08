module VersatileDiamond
  module Organizers

    # Provides methods for cleaning links
    module LinksCleaner
    private

      def erase_excess_positions(links)
        links.each_with_object({}) do |(v, rels), result|
          result[v] = rels.reject { |w, r| excess_position?(r, v, w) }
        end
      end

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
        unless first.lattice == second.lattice
          raise 'Wrong position between atoms that belongs to different lattices'
        end
        first
      end
    end

  end
end
