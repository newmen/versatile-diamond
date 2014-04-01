module VersatileDiamond
  module Organizers

    # Contain some reaction and set of dependent reactions
    # @abstract
    class DependentReaction
      extend Forwardable

      attr_reader :reaction

      # Stores wrappable reaction
      # @param [Concepts::UbiquitousReaction] reaction the wrappable reaction
      def initialize(reaction)
        @reaction = reaction
      end

      def_delegators :@reaction, :name, :full_rate, :swap_source, :used_keynames_of

      # Iterates each not simple specific source spec
      # @yield [Concepts::SpecificSpec] do with each one
      def each_source(&block)
        (reaction.source - reaction.simple_source).each(&block)
      end

      # Checks that reactions are identical
      # @param [DependentReaction] other the comparable wrapped reaction
      # @return [Boolean] same or not
      def same?(other)
        self.class == other.class && reaction.same?(other.reaction)
      end

    protected



    end

  end
end
