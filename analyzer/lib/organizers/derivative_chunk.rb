module VersatileDiamond
  module Organizers

    # Describes the chunk which constructs from another chunks and can builds lateral
    # reaction for which it was builded
    class DerivativeChunk < BaseChunk
      include Modules::ExtendedCombinator
      include Modules::ListsComparer
      include ChunksComparer
      include DrawableChunk
      include TailedChunk

      # Provides common veiled specs cache for correct merge different chunks
      class << self
        attr_reader :veiled_cache

        # Initiates the veiled specs cache
        def init_veiled_cache!
          @veiled_cache = {}
        end
      end

      attr_reader :parents, :links, :targets

      # Constructs the chunk by another chunks
      # @param [DependentTypicalReaction] typical_reaction for which the new lateral
      #   reaction will be created later
      # @param [Array] chunks the parents of building chunk
      # @param [Hash] variants is the full table of chunks combination variants for
      #   calculate maximal compatible full rate value
      def initialize(typical_reaction, chunks, variants)
        super()

        @typical_reaction = typical_reaction

        raise 'Derivative chunk should have more that one parent' if chunks.size < 2
        @parents = chunks
        @variants = variants

        @targets = merge_targets(chunks)
        @links = merge_links(chunks)

        @_lateral_reaction, @_tail_name = nil
      end

      # Makes the lateral reaction which contain current chunk
      # @return [CombinedLateralReaction] instance of new lateral reaction
      def lateral_reaction
        @_lateral_reaction ||=
          CombinedLateralReaction.new(@typical_reaction, self, full_rate)
      end

      # The chunk which created by user described lateral reaction is original
      # @return [Boolean] true
      def original?
        false
      end

      def inspect
        "Derivative chunk of #{tail_name}"
      end

    private

      # Gets set of targets from all passed containers
      # @param [Array] chunks the list of chunks which targets will be merged
      # @return [Array] where first item is set of targets and second item is mirror
      #   of other same targets to targets which presented in first item
      def merge_targets(chunks)
        chunks.map { |chunk| chunk.mapped_targets.values.to_set }.reduce(:+)
      end

      # Merges all links from chunks list
      # @param [Array] chunks which links will be merged
      # @return [Hash] the common links hash
      def merge_links(chunks)
        used_non_target_specs = []

        chunks.each_with_object({}) do |chunk, acc|
          used_non_target_specs_mirror = {}

          mirror = -> sa do
            typical_target = chunk.mapped_targets[sa]
            if typical_target
              typical_target
            else
              spec, atom = sa
              cached_spec =
                if used_non_target_specs_mirror[spec]
                  used_non_target_specs_mirror[spec]
                elsif !used_non_target_specs.include?(spec)
                  used_non_target_specs << spec
                  used_non_target_specs_mirror[spec] = spec
                else
                  rels = chunk.links.select { |(s, _), _| spec == s }
                  if self.class.veiled_cache[rels]
                    used_non_target_specs_mirror[spec] = self.class.veiled_cache[rels]
                  else
                    veiled_spec = Concepts::VeiledSpec.new(spec)
                    used_non_target_specs_mirror[spec] = veiled_spec
                    self.class.veiled_cache[rels] = veiled_spec
                  end
                end

              cached_atom = cached_spec.atom(spec.keyname(atom))
              raise 'Incorrect cached atom' unless cached_atom

              [cached_spec, cached_atom]
            end
          end

          chunk.links.each do |spec_atom, rels|
            key = mirror[spec_atom]
            acc[key] ||= []
            acc[key] += rels.map { |t, r| [mirror[t], r] }
          end
        end
      end

      # Gets the list of parents tail names
      # @return [Array] the list of tail names
      def tail_names
        parents.map(&:tail_name)
      end

      # Provides full rate of reaction which could be if lateral environment is same
      # as chunk describes
      #
      # @return [Float] the rate of reaction which use the current chunk
      def full_rate
        tf_rate = @typical_reaction.full_rate
        original_parents = parents.select(&:original?)
        all_possible_combinations(original_parents).reverse.each do |slice|
          rates = slice.map do |cs|
            value = @variants[Multiset.new(cs)]
            value && value.original? && value.full_rate
          end

          good_rates = rates.select { |x| x }
          # selecs maximal different rate
          return good_rates.max_by { |x| (tf_rate - x).abs } unless good_rates.empty?
        end

        tf_rate
      end

      # Gets all possible combinations of array items
      # @param [Array] array which items will be combinated
      # @return [Array] the list of all posible combinations
      def all_possible_combinations(array)
        sliced_combinations(array, 1).map(&:uniq)
      end
    end

  end
end
