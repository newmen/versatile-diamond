module VersatileDiamond
  module Organizers

    # Provides methods for cleaning links
    module LinksCleaner
      include Modules::ExcessPositionChecker

    private

      # Gets the links without excess positions
      # @param [Hash] links between atoms
      # @return [Hash] the links without excess positions
      def erase_excess_positions(links)
        erase_excess_relations_if(links) { |r, v, w| excess_position?(r, v, w) }
      end

      # Drops relations by passed block
      # @param [Hash] links between atoms
      # @yield [Concepts::Bond, Concepts::Atom, Concepts::Atom]
      # @return [Hash] the links without excess positions
      def erase_excess_relations_if(links, &block)
        links.each_with_object({}) do |(v, rels), result|
          result[v] = rels.reject { |w, r| block[r, v, w] }
        end
      end
    end

  end
end
