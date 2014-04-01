module VersatileDiamond
  module Organizers

    # Wraps ubiquitous reaction
    class DependentUbiquitousReaction < DependentReaction
      require Collector

      def initialize(reaction)
        super
        @complexes = nil
      end

      collector_methods :complex

      # Organize dependencies from another not ubiquitous reactions
      # @param [Array] not_ubiquitous_reactions the possible children
      def organize_dependencies!(not_ubiquitous_reactions)
        # number of termination specs should == 1
        term_spec = (@source - simple_source).first

        condition = -> spec1, spec2 { spec1.same?(spec2) }

        not_ubiquitous_reactions.each do |possible_child|
          simples_are_identical = lists_are_identical?(
            simple_source, possible_child.simple_source, &condition) &&
              lists_are_identical?(
                simple_products, possible_child.simple_products, &condition)

          next unless simples_are_identical &&
            possible_child.complex_source_covered_by?(term_spec)

          more_complex << possible_child
        end
      end
    end

  end
end
