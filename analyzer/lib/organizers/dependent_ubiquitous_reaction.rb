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
      # def organize_dependencies!(not_ubiquitous_reactions, specific_cache)
        not_ubiquitous_reactions.each do |possible|
          if simples_are_identical(possible)
            if possible.source_covered_by?(termination)
              # specific_cache[possible.name]
              store_complex(possible)
            end
          end
        end
      end

    private

      def simples_are_identical(possible)
        cm = method(:compare_specs)
        lists_are_identical?(simple_source, possible.simple_source, &cm) &&
          lists_are_identical?(simple_products, possible.simple_products, &cm)
      end

      def compare_specs(spec1, spec2)
        spec1.same?(spec2)
      end
    end

  end
end
