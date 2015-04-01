module VersatileDiamond
  module Organizers

    # Provides methods for minuend behavior
    module MinuendChunk
      include Organizers::ChunksComparer
      include Organizers::Minuend

    protected

      # Gets the array of used relations of passed spec-atom instance
      # @param [Array] sa the array with two items: spec and atom
      # @return [Array] the array of relations which belongs to passed spec-atom
      #   instance
      def used_relations_of(sa)
        links[sa].map(&:last)
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

      # Provides comparison by class of each instance
      # @param [MinuendSpec] other see at #<=> same argument
      # @return [Integer] the result of comparation
      def order_classes(other, &block)
        typed_order(self, other, Chunk) do
          typed_order(self, other, ChunkResidual, &block)
        end
      end

      # Also checks that key is one of targets
      # @param [Array] _ does not used
      # @param [Array] key the one of links graph key
      # @return [Boolean] is used key or not
      # @override
      def used?(_, key)
        targets.include?(key) || super
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
