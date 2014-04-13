module VersatileDiamond
  module Organizers

    # Contain some reaction and set of dependent reactions
    # @abstract
    class DependentReaction
      extend Forwardable
      extend Collector

      def_delegators :@reaction, :name, :full_rate, :swap_source, :used_keynames_of
      collector_methods :complex
      attr_reader :reaction, :parent

      # Stores wrappable reaction
      # @param [Concepts::UbiquitousReaction] reaction the wrappable reaction
      def initialize(reaction)
        @reaction = reaction
      end

      # Iterates each not simple specific source spec
      # @yield [Concepts::SpecificSpec] do with each one
      def each_source(&block)
        surface_source.each(&block)
      end

      # Checks that reactions are identical
      # @param [DependentReaction] other the comparable wrapped reaction
      # @return [Boolean] same or not
      def same?(other)
        reaction.same?(other.reaction)
      end

    protected

      def_delegators :@reaction, :source, :simple_source, :simple_products

      # Gets surface source species
      # @return [Array] the array of not simple species
      def surface_source
        source.reject(&:gas?)
      end

      # Stores the parent of reaction
      # @param [DependentReaction] parent the parent of current reaction
      def store_parent(parent)
        raise 'Parent already set' if @parent
        @parent = parent
        parent.store_complex(self)
      end
    end

  end
end
