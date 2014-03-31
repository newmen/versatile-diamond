module VersatileDiamond
  module Organizers

    # Contain some reaction and set of dependent reactions
    class DependentReaction
      extend Forwardable

      # Stores wrappable reaction
      # @param [Concepts::UbiquitousReaction] reaction the wrappable reaction
      def initialize(reaction)
        @reaction = reaction
      end

      def_delegators :@reaction, :full_rate, #:simple_source, :simple_products,
        :swap_source, :used_keynames_of

      def theres
        @reaction.theres.map { |there| DependentThere.new(there) }
      end

      def each_source(&block)
        (@reaction.source - @reaction.simple_source).each(&block)
      end

    end

  end
end
