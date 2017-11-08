module VersatileDiamond
  module Organizers

    # Contain some reaction and set of dependent reactions
    # @abstract
    class DependentReaction
      extend Forwardable
      extend Collector

      collector_methods :child
      attr_reader :reaction, :parent
      def_delegators :reaction, :name, :swap_on, :use_similar?, :changes_num,
        :full_rate, :rate_tuple

      # Stores wrappable reaction
      # @param [Concepts::UbiquitousReaction] reaction the wrappable reaction
      def initialize(reaction)
        @reaction = reaction
        @parent = nil
      end

      # Iterates each not simple specific spec
      # @param [Symbol] target the type of iterating species
      # @yield [Concepts::SpecificSpec] do with each one
      def each(target, &block)
        send(target).dup.each(&block)
      end

      # Checks that reactions are identical
      # @param [DependentReaction] other the comparable wrapped reaction
      # @return [Boolean] same or not
      def same?(other)
        reaction.same?(other.reaction)
      end

      # Check that reaction have gas ion reagent
      # @return [Boolean] is reaction specific of ubiquitous or not
      def local?
        parent && !simple_source.empty?
      end

      def formula
        reaction.to_s
      end

      def to_s
        "(#{name}, [#{parent}], [#{children.map(&:name).join('; ')}])"
      end

      def inspect
        to_s
      end

    protected

      def_delegators :reaction, :source, :products, :simple_source, :simple_products

      # Stores the parent of reaction
      # @param [DependentReaction] parent the parent of current reaction
      def store_parent(parent)
        raise 'Parent already set' if @parent
        @parent = parent
        parent.store_child(self)
      end
    end

  end
end
