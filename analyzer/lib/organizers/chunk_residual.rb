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

        @_independent_links, @_independent_chunk = nil
      end

      # Makes independent chunk from not fully matched residual
      # @return [IndependentChunk] the chunk which builds from not fully matchde
      #   residual
      def independent_chunk
        return @_independent_chunk if @_independent_chunk

        if fully_matched?
          raise 'Independent chunk could not be for fully matched residual'
        end

        @_independent_chunk =
          IndependentChunk.new(owner, bonded_targets, independent_links)
      end

      # Checks that current chunk residual is fully matched
      # @return [Boolean] is fully matched residual or not
      def fully_matched?
        parents.empty? || lists_are_identical?(links.keys, targets.to_a, &:==)
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

      # Gets list of targets which bonded with non target vertices in links graph
      # @return [Set] the list of bonded targets
      def bonded_targets
        targets.each do |tg|
          if !independent_links[tg] && !links[tg].select { |o, _| links[o] }.empty?
            raise 'Could not find target'
          end
        end
        targets.select { |tg| independent_links[tg] }.to_set
      end

      # Collects links for independent chunk
      # @return [Hash] the links for independent chunk
      def independent_links
        @_independent_links ||= links.each_with_object({}) do |(k, rels), acc|
          linked_rels = rels.select { |o, _| links[o] }
          acc[k] = linked_rels unless linked_rels.empty?
        end
      end
    end

  end
end
