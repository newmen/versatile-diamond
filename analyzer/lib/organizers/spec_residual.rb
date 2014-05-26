module VersatileDiamond
  module Organizers

    # Contain some residual of find diff between base species
    class SpecResidual
      include Minuend

      class << self
        # Gets empty residual instance
        # @return [SpecResidual] the empty residual instance
        def empty
          new({})
        end
      end

      attr_reader :links

      # Initialize residual by hash of links and residual border atoms
      # @param [Hash] links the links between some atoms
      def initialize(links)
        @links = links
      end

      # Checks that other spec has same border atoms and links between them
      # @param [DependentBaseSpec] other the comparable spec
      # @return [Boolean] same or not
      def same?(other)
        return false unless atoms_num == other.atoms_num
        intersec = mirror_to(other)

        intersec.size == atoms_num && intersec.all? do |a, b|
          !different_relations?(other, a, b)
        end
      end

    private

      # Checks that relations of both atom have same sets
      # @param [DependentBaseSpec | DependentSpecificSpec] other same as #- argument
      # @param [Concepts::SpecificAtom | Concepts::Atom | Concepts::AtomReference]
      #   spec_atom same as #are_atoms_different? argument
      # @param [Concepts::Atom | Concepts::AtomReference] base_atom same as
      #   #are_atoms_different? argument
      # @return [Boolean] are different or not
      def different_relations?(*args)
        different_by?(:relations_of, *args)
      end
    end

  end
end
