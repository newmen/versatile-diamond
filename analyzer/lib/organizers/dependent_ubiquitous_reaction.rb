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

      # Organize dependencies from another not ubiquitous reactions
      # @param [Array] not_ubiquitous_reactions the possible children
      def organize_dependencies!(not_ubiquitous_reactions)
        condition = -> spec1, spec2 { spec1.same?(spec2) }

        not_ubiquitous_reactions.each do |possible|
          simples_are_identical = lists_are_identical?(
            simple_source, possible.simple_source, &condition) &&
              lists_are_identical?(
                simple_products, possible.simple_products, &condition)

          if simples_are_identical && possible.source_covered_by?(termination)
            store_complex(possible)
          end
        end
      end
    end

  end
end
