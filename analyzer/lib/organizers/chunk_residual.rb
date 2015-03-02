module VersatileDiamond
  module Organizers

    # Stores the residual of chunk
    class ChunkResidual
      include MinuendChunk
      extend Forwardable

      class << self
        # Gets empty residual instance
        # @param [Chunk] owner see at #new same argument
        # @return [ChunkResidual] the empty residual instance
        def empty(owner)
          new(owner, owner.links, [])
        end
      end

      attr_reader :links, :parents

      # Initializes the chunk residual
      # @param [Chunk] owner chunk
      # @param [Hash] links of residual
      # @param [Array] parents chunks
      def initialize(owner, links, parents)
        @owner = owner
        @links = links
        @parents = parents
      end

      # Also checks that parents are equal too
      # @param [ChunkResidual] other the comparable chunk
      # @return [Boolean] is same other chunk or not
      def same?(other)
        # TODO: owners do not comparing
        super && lists_are_identical?(parents, other.parents, &:==)
      end

    protected

      attr_reader :owner
      def_delegator :owner, :targets

    private

      # Also store own parents in result
      # @return [ChunkResidual] the subtraction result
      # @override
      def subtract(*)
        diff = super
        self.class.new(diff.owner, diff.links, parents + diff.parents)
      end

      # Provides the lowest level of comparing two minuend instances
      # @param [MinuendChunk] other comparing instance
      # @return [Proc] the core of comparison
      def comparing_core(other)
        if self.class == other.class
          -> { other.parents.size <=> parents.size }
        else
          -> { 1 }
        end
      end
    end

  end
end
