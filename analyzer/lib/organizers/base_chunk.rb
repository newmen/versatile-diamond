module VersatileDiamond
  module Organizers

    # Provides base logic for chunks
    # @abstract
    class BaseChunk

      # Initializes internal caches of all chunks
      def initialize
        @_target_specs, @_sidepiece_specs, @_clean_links = nil
      end

      # Gets clean graph of relations between targets and sidepiece species
      # @return [Hash] the cleaned graph which contain just significant relations
      def clean_links
        @_clean_links ||= links.each.each_with_object({}) do |(spec_atom, rels), acc|
          spec = spec_atom.first
          new_rels = rels.reject { |(s, _), _| spec == s }
          acc[spec_atom] = new_rels unless new_rels.empty?
        end
      end

      # Gets set of target species
      # @return [Set] the set of using target species
      def target_specs
        @_target_specs ||= targets.map(&:first).to_set
      end

      # Gets set of sidepiece species
      # @return [Set] the set of using non targets species
      def sidepiece_specs
        @_sidepiece_specs ||= links.keys.map(&:first).to_set - target_specs
      end
    end

  end
end
