module VersatileDiamond
  module Organizers

    # Wraps structural reaction without lateral interactions
    class DependentTypicalReaction < DependentSpecReaction

      def_delegator :reaction, :complex_source_spec_and_atom

      # Selects complex source spec and them changed atom
      # @return [SpecificSpec] the covered spec
      def source_covered_by(termination_spec)
        spec, atom = reaction.complex_source_spec_and_atom
        termination_spec.cover?(spec, atom) ? spec : nil
      end

      # Typical reaction isn't lateral
      # @return [Boolean] false
      def lateral?
        false
      end

      # Organize dependencies from another lateral reactions
      # @param [Array] lateral_reactions the possible children
      def organize_dependencies!(lateral_reactions)
        applicants = []
        lateral_reactions.each do |possible|
          applicants << possible if reaction.same_positions?(possible.reaction)
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

        applicants.each { |possible| possible.store_parent(self) }
      end
    end

  end
end
