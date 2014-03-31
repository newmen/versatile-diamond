module VersatileDiamond
  module Organizers

    # Contain some reaction and set of dependent reactions
    class DependentReaction
      extend Forwardable

      attr_reader :reaction

      # Stores wrappable reaction
      # @param [Concepts::UbiquitousReaction] reaction the wrappable reaction
      def initialize(reaction)
        @reaction = reaction
      end

      def_delegators :@reaction, :name, :full_rate,
        :swap_source, :used_keynames_of

      # Iterates each not simple specific source spec
      # @yield [Concepts::SpecificSpec] do with each one
      def each_source(&block)
        (reaction.source - reaction.simple_source).each(&block)
      end

      # @raise [NoMethodError] unless reaction is lateral reaction
      def theres
        reaction.theres.map { |there| DependentThere.new(there) }
      end

      def same?(other)
        reaction.class == other.reaction.class && reaction.same?(other.reaction)
      end

    end

  end
end
