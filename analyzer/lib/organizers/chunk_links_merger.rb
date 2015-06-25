module VersatileDiamond
  module Organizers

    # Merges the links of derivative chunk
    class ChunkLinksMerger
      # Provides common veiled specs cache for correct merge different chunks
      class << self
        # Initiates the veiled specs cache
        def init_veiled_cache!
          @global_cache = {}
        end

        # Gets global cache of veiled specs
        def global_cache
          @global_cache || init_veiled_cache!
        end
      end

      # Initializes the internal caches
      def initialize
        @instance_cache = Set.new
      end

      # @return [Hash] the acc with links
      def merge(total_links, chunk)
        local_cache = {}

        chunk.links.each_with_object(total_links) do |(spec_atom, rels), acc|
          key = key(local_cache, chunk, spec_atom)
          acc[key] ||= []
          acc[key] += rels.map { |sa, r| [key(local_cache, chunk, sa), r] }
        end
      end

    private

      # Gets the correct key for common links graph
      # @param [Hash] local_cache the changable cache for current local merge
      # @param [BaseChunk] chunk which links merges to total links
      # @param [Array] spec_atom is the original vertex from some chunk links graph
      # @return [Array] the correct key for result links graph
      def key(local_cache, chunk, spec_atom)
        chunk.mapped_targets[spec_atom] ||
          cached_target(local_cache, chunk, *spec_atom)
      end

      # Finds correct cached key for common links graph
      # @param [Hash] local_cache the changable cache for current local merge
      # @param [BaseChunk] chunk which links merges to total links
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] spec
      #   which veiled analog will be checked
      # @param [Concepts::Atom | Concepts::SpecificAtom | Concepts::AtomReference] atom
      #   which mirror in veiled spec will be gotten
      # @return [Array] the correct cached key for result links graph
      def cached_target(local_cache, chunk, spec, atom)
        cached_spec = find_cached_spec(local_cache, chunk, spec)
        cached_atom = cached_spec.atom(spec.keyname(atom))
        raise 'Incorrect cached atom' unless cached_atom

        [cached_spec, cached_atom]
      end

      # Checks all level caches and find correct spec for
      # @param [Hash] local_cache the changable cache for current local merge
      # @param [BaseChunk] chunk which links merges to total links
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] spec
      #   which veiled analog will be checked
      # @return [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] the
      #   cached spec
      def find_cached_spec(local_cache, chunk, spec)
        if local_cache[spec]
          local_cache[spec]
        elsif @instance_cache.include?(spec)
          rels = chunk.links.select { |(s, _), _| spec == s }
          find_veiled_spec(local_cache, spec, [spec, rels])
        else
          @instance_cache << spec
          local_cache[spec] = spec
        end
      end

      # Checks local and global caches for find correct veiled spec
      # @param [Hash] local_cache the changable cache for current local merge
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] spec
      #   which veiled analog will be checked
      # @param [Array] global_key the spec and it relations in merging links
      # @return [Concepts::VeiledSpec] the veiled spec
      def find_veiled_spec(local_cache, spec, global_key)
        global_veiled = self.class.global_cache[global_key]
        if global_veiled
          check_instance_spec(local_cache, spec, global_veiled, global_key)
        else
          veiled_spec = Concepts::VeiledSpec.new(spec)
          self.class.global_cache[global_key] = veiled_spec
          @instance_cache << veiled_spec
          local_cache[spec] = veiled_spec
        end
      end

      # Checks that global veiled spec was not used in instance cache and if used then
      # recursive find in global cache again with more complex global key
      #
      # @param [Hash] local_cache the changable cache for current local merge
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
      #   original_spec which uses as key of local cache or as target of new veiled
      #   spec
      # @param [Concepts::VeiledSpec] global_veiled which was fetched from global cache
      # @param [Object] global_key the relations of passed spec in merging links
      # @return [Concepts::VeiledSpec] the veiled spec
      def check_instance_spec(local_cache, original_spec, global_veiled, global_key)
        if @instance_cache.include?(global_veiled)
          complex_key = [global_veiled, global_key.last]
          find_veiled_spec(local_cache, original_spec, complex_key)
        else
          @instance_cache << global_veiled
          local_cache[original_spec] = global_veiled
        end
      end
    end

  end
end
