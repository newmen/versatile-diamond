module VersatileDiamond
  module Organizers

    # Provides methods for minuend behavior
    module MinuendChunk
      include Organizers::Minuend

      # Compares two chunk instances and check that them are same
      # @param [MinuendChunk] other chunk which will be compared
      # @return [Boolean] is same other chunk or not
      def same?(other)
        return false unless self.class == other.class && targets == other.targets
        lsz = links.size
        other.links.size == lsz &&
          (targets.size == lsz || mirror_to(other).size == lsz)
      end

    protected

      # Gets the array of used relations of passed spec-atom instance
      # @param [Array] sa the array with two items: spec and atom
      # @return [Array] the array of relations which belongs to passed spec-atom
      #   instance
      def used_relations_of(sa)
        links[sa].map(&:last)
      end

      # Checks that passed spec-atom instance is target of current chunk
      # @param [Array] sa the one of key of links
      # @return [Boolean] is target spec-atom or not
      def target?(sa)
        targets.include?(sa)
      end

    private

      # Makes difference between current and other instances
      # @param [MinuendChunk] other chunk which will be subtract from current
      # @param [Hash] mirror from self to other chunk
      # @return [ChunkResidual] the residual of diference between arguments or nil if
      #   it doesn't exist
      def subtract(other, mirror)
        ChunkResidual.new(owner, rest_links(other, mirror), [other])
      end

      # Makes mirror with other chunk or chunk resudual
      # @param [MinuendChunk] other chunk to which the mirror will be builded
      # @return [Hash] the mirror from self chunk to other chunk
      def mirror_to(other)
        Mcs::SpeciesComparator.make_mirror(self, other) do |_, _, sa1, sa2|
          ts = [target?(sa1), other.target?(sa2)]
          (ts.all? || !ts.any?) && same_sa?(sa1, sa2)
        end
      end

      # Compares two spec-atom instances
      # @param [Array] sa1 the first spec-atom instance
      # @param [Array] sa2 the second spec-atom instance
      # @return [Boolean] is same spec-atom instances or not
      def same_sa?(sa1, sa2)
        (spec1, atom1), (spec2, atom2) = sa1, sa2
        return false unless spec1.equal?(spec2) || spec1.links.size == spec2.links.size

        insecs =
          Mcs::SpeciesComparator.intersec(spec1, spec2, collaps_multi_bond: true)

        insecs.size > 0 && insecs.first.size == spec1.links.size &&
          insecs.any? { |ic| ic.include?([atom1, atom2]) }
      end

      # Provides comparison by class of each instance
      # @param [MinuendSpec] other see at #<=> same argument
      # @return [Integer] the result of comparation
      def order_classes(other, &block)
        typed_order(self, other, Chunk) do
          typed_order(self, other, ChunkResidual, &block)
        end
      end

      # Checks that passed neibhour key is the same as cheking key
      # @param [Array] _ does not used
      # @param [Array] neighbour_key the neighbour key of first argument
      # @param [Array] cheking_key the key which checks that it used
      # @param [Concepts::Bond] _ does not used
      # @return [Boolean] are same neighbour key and cheking key or not
      def neighbour?(_, neighbour_key, checking_key, _)
        neighbour_key == checking_key
      end
    end

  end
end
