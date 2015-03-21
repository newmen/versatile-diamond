module VersatileDiamond
  module Organizers

    # Contain some reaction and set of dependent reactions
    # @abstract
    class DependentReaction
      include Modules::OrderProvider
      include MultiParentsAndChildren
      include InspecableDependentInstance
      extend Forwardable

      attr_reader :reaction
      def_delegators :@reaction, :name, :full_rate, :swap_source, :use_similar_source?,
        :changes_num

      # Stores wrappable reaction
      # @param [Concepts::UbiquitousReaction] reaction the wrappable reaction
      def initialize(reaction)
        @reaction = reaction
      end

      # Compares two reaction instances
      # @param [UbiquitousReaction] other comparing reaction
      # @return [Integer] the comparing result
      def <=> (other)
        typed_order(self, other, DependentLateralReaction) do
          typed_order(self, other, DependentTypicalReaction) do
            typed_order(self, other, DependentUbiquitousReaction) do
              order(self, other, :changes_num) do
                order(self, other, :source, :size) do
                  order(self, other, :products, :size) do
                    partial_order(other)
                  end
                end
              end
            end
          end
        end
      end

      # Iterates each not simple specific source spec
      # @yield [Concepts::SpecificSpec] do with each one
      def each_source(&block)
        source.dup.each(&block)
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
        !(parents.empty? || simple_source.empty?)
      end

      def formula
        reaction.to_s
      end

    protected

      def_delegators :@reaction, :source, :products, :simple_source, :simple_products

      # Provides partial order which could be overriden in children classes
      # @param [DependentReaction] other comparable reaction which have same type as
      #   self reaction
      # @return [Integer] the result of comparison
      def partial_order(other)
        0
      end
    end

  end
end
