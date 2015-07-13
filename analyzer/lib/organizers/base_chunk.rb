module VersatileDiamond
  module Organizers

    # Provides base logic for chunks
    # @abstract
    class BaseChunk

      class << self
        include Modules::OrderProvider

        # This method needs because Chunk instances already have #<=> method for
        # ordering in dynamic table
        #
        # @param [Array] chunks the unordered list of chunks
        # @option [Symbol] :direction can have :asc or :desc values
        # @return [Array] ordered list of chunks
        # TODO: dynamic table is not need for chunks!
        def reorder(chunks, direction: :asc)
          k = direction == :desc ? -1 : 1
          chunks.sort do |a, b|
            k * typed_order(a, b, DerivativeChunk) do
              typed_order(a, b, Chunk) do
                typed_order(a, b, IndependentChunk) do
                  order(a, b, :clean_links, :size) do
                    order(a, b, :total_links_num)
                  end
                end
              end
            end
          end
        end
      end

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

    private

      # Counts total number of links
      # @return [Integer] the number of links
      def total_links_num
        links.reduce(0) { |acc, rels| acc + 1 + rels.size }
      end
    end

  end
end
