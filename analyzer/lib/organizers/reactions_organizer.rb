module VersatileDiamond
  module Organizers

    # Provides methods for reactions organization
    module ReactionsOrganizer

      # Organize dependencies between passed reactions.
      # Also organize dependencies between termination species and their complex
      # parents.
      #
      # @param [Hash] term_ss the specs cache where names of termination specs are used
      #   as keys and real dependent termination specs as values
      # @param [Hash] non_term_ss the specs cache where base and specific dependent
      #   specs contained
      # @param [Array] reactions_lists the array of 3 arguments where first is
      #   dependent ubiquitous reactions list, second is dependent typical reactions
      #   list and last is dependent lateral reactions list
      def organize_reactions_dependencies!(term_ss, non_term_ss, *reactions_lists)
        ubiq_rs, typical_rs, lateral_rs = reactions_lists
        non_ubiq_rs = typical_rs + lateral_rs

        organize_ubiquitous_reactions_deps!(term_ss, non_term_ss, *reactions_lists)
        organize_complex_reactions_deps!(typical_rs, lateral_rs)
      end

    private

      # Organize dependencies between ubiquitous reactions
      # @param [Hash] term_ss see at #organize_reactions_dependencies! same arg
      # @param [Hash] non_term_ss  see at #organize_reactions_dependencies! same arg
      # @param [Array] reactions_lists the array of 2 arguments where first is
      #   dependent ubiquitous reactions list, second is common list of dependent
      #   typical reactions and last lateral reactions list
      def organize_ubiquitous_reactions_deps!(term_ss, non_term_ss, *reactions_lists)
        ubiq_rs, non_ubiq_rs = reactions_lists
        ubiq_rs.each do |reaction|
          reaction.organize_dependencies!(non_ubiq_rs, term_ss, non_term_ss)
        end
      end

      # Organize dependencies between typical and lateral reactions
      # @param [Array] typical_rs the list of dependent typical reactions
      # @param [Array] lateral_rs the list of dependent lateral reactions
      # @return [Array] the list of new combined lateral reactions which were missed by
      #   user
      def organize_complex_reactions_deps!(typical_rs, lateral_rs)
        typical_rs.each { |reaction| reaction.organize_dependencies!(lateral_rs) }
        typical_rs.flat_map(&:combine_children_laterals!)
      end

      # Reorganizes the specs of children reactions
      # @param [Array] typical_crs the list of concept typical reactions
      def reorganize_children_specs!(typical_crs)
        typical_crs.each(&:reorganize_children_specs!)
      end
    end

  end
end
