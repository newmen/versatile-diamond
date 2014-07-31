module VersatileDiamond
  module Organizers

    # Contain some residual of find diff between base species
    class SpecResidual
      include Minuend

      class << self
        # Gets empty residual instance
        # @return [SpecResidual] the empty residual instance
        def empty
          new({}, {})
        end
      end

      attr_reader :links

      # Initialize residual by hash of links and residual border atoms
      # @param [Hash] links the links between some atoms
      # @param [hash] references to atoms of parent species
      def initialize(links, references)
        @links = links
        @references = references
      end

      # Pass to super method current references for accumulate them all in minimal
      # residual
      #
      # @param [DependentBaseSpec | DependentSpecificSpec] other see at #super same arg
      # @override
      def - (other)
        super(other, @references)
      end

      # Gets instance of twin atom from parent spec
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom] atom
      #   the atom of current instance for which twin was found
      # @return [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   the correspond atom from parent specie
      def twin(atom)
        # TODO: now #twin used only for detect additional atoms in atom sequence logic
        all_twins(atom).first
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

      # Gets all twin instances of atom from parent spec
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom] atom
      #   see at #first_twin same argument
      # @return [Array] the array of twin instances
      def all_twins(atom)
        @references[atom] || []
      end
    end

  end
end
