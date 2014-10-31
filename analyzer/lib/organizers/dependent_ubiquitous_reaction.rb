module VersatileDiamond
  module Organizers

    # Wraps ubiquitous reaction
    class DependentUbiquitousReaction < DependentReaction
      include Modules::ListsComparer

      # Gets termination spec from reaction. The number of termination specs
      # should == 1
      #
      # @return [Concepts::TerminationSpec] the termiation spec
      def termination
        not_simple_source.first
      end

      # Ubiquitous reaction isn't lateral
      # @return [Boolean] false
      def lateral?
        false
      end

      # Organize dependencies from another not ubiquitous reactions
      # @param [Array] not_ubiquitous_reactions the possible children
      # @param [Hash] terms_cache the cache of terminations where the keys are names
      #   of specs and values are terminations
      # @param [Hash] specs_cache the cache of spec where the keys are names of specs
      #   and values are specs
      def organize_dependencies!(not_ubiquitous_reactions, terms_cache, specs_cache)
        not_ubiquitous_reactions.each do |possible|
          if simples_are_identical?(possible)
            spec = possible.source_covered_by(termination)
            if spec
              terms_cache[termination.name].store_parent(specs_cache[spec.name])
              possible.store_parent(self)
            end
          end
        end
      end

    private

      # Checks that simple species are identical in possible parent reaction
      # @param [DependentTypicalReaction | DependentLateralReaction] possible the
      #   checkable possible parent reaction
      # @return [Boolean] are identical or not
      def simples_are_identical?(possible)
        lists_are_identical?(simple_source, possible.simple_source, &:same?) &&
          lists_are_identical?(simple_products, possible.simple_products, &:same?)
      end
    end

  end
end
