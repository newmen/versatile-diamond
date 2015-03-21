module VersatileDiamond
  module Organizers

    # Provides common methods for finite chunk classes
    # @abstract
    class ChunkCore
      extend Organizers::Collector

      collector_methods :parent
      attr_reader :links

      # Initializes the core by entities which contain targets and links
      # @param [Array] entities by which the core of chunk will be inited
      def initialize(entities)
        @targets = merge_targets(entities)
        @links = merge_links(entities)
      end

      def inspect
        "Chunk of #{lateral_reaction.name}"
      end

    protected

      attr_reader :targets

    private

      # Gets set of targets from all passed containers
      # @param [Array] targets_containers the list of entities which have targets
      # @return [Set] the set of targets
      def merge_targets(targets_containers)
        targets_containers.map(&:targets).reduce(:+)
      end

      # Adsorbs all links from links list
      # @param [Array] links_list which items will be merged
      # @return [Hash] the common links hash
      def merge_links(links_containers)
        links_containers.each_with_object({}) do |entity, acc|
          entity.links.each do |sa1, rels|
            acc[sa1] ||= []
            acc[sa1] += rels
          end
        end
      end
    end

  end
end
