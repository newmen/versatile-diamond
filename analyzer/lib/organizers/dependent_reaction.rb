module VersatileDiamond
  module Organizers

    # Contain some reaction and set of dependent reactions
    # @abstract
    class DependentReaction
      extend Forwardable
      extend Collector

      attr_reader :reaction, :parent
      collector_methods :complex
      def_delegators :@reaction, :name, :full_rate, :swap_source, :used_keynames_of,
        :size

      # Stores wrappable reaction
      # @param [Concepts::UbiquitousReaction] reaction the wrappable reaction
      def initialize(reaction)
        @reaction = reaction
      end

      # Iterates each not simple specific source spec
      # @yield [Concepts::SpecificSpec] do with each one
      def each_source(&block)
        not_simple_source.each(&block)
      end

      # Checks that reactions are identical
      # @param [DependentReaction] other the comparable wrapped reaction
      # @return [Boolean] same or not
      def same?(other)
        reaction.same?(other.reaction)
      end

      def formula
        reaction.to_s
      end

    protected

      def_delegators :@reaction, :source, :products, :simple_source, :simple_products

      # Gets not simple source species
      # @return [Array] the array of not simple species
      def not_simple_source
        source - simple_source
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
