module VersatileDiamond
  module Organizers

    # Wraps structural reaction without lateral interactions
    class DependentTypicalReaction < DependentReaction
      # Selects complex source specs and them changed atom

      # @return [Boolean] covered or not
      def source_covered_by?(termination_spec)
        spec, atom = reaction.complex_source_spec_and_atom
        termination_spec.cover?(spec, atom)
      end

      # Organize dependencies from another lateral reactions
      # @param [Array] lateral_reactions the possible children
      def organize_dependencies!(lateral_reactions)
        applicants = []
        lateral_reactions.each do |possible|
          applicants << possible if same?(possible)
        end

        return if applicants.empty?

        loop do
          inc = applicants.select do |possible|
            applicants.find do |unr|
              possible != unr && possible.complexes.include?(unr)
            end
          end
          break if inc.empty?
          applicants = inc
        end

        applicants.each { |possible| store_complex(possible) }
      end
    end

  end
end
