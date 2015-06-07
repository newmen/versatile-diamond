module VersatileDiamond
  using Patches::RichArray

  module Organizers

    # Tries to combine several chunks for gets new children of wrapped dependent
    # typical rection
    class ChunksCombiner
      include Mcs::SpecsAtomsComparator
      include Modules::ListsComparer

      # Initializes combiner by target typical reaction
      # @param [DependentTypicalReaction] typical_reaction for which new lateral
      #   reactions will be found (or not)
      def initialize(typical_reaction)
        @typical_reaction = typical_reaction

        @_general_targets = nil
      end

      # Combines children lateral raection chunks and produce new lateral reactions
      # @return [Array] the list of combined lateral reactions
      def combine(chunks)
        variants = recombine_variants(collect_variants(chunks))
        unregistered_chunks = variants.values.select do |chunk|
          chunk && !(chunks.include?(chunk) && chunk.original?)
        end

        unregistered_chunks.map(&:lateral_reaction)
      end

    private

      # Collects variants from passed chunks
      # @param [Array] chunks from which the variants will be collected
      # @return [Hash] the initial hash of combination variants
      def collect_variants(chunks)
        variants = Hash[chunks.map { |ch| [Multiset[ch], ch] }]
        if chunks.all? { |ch| ch.parents.empty? }
          variants = extend_variants(variants, chunks)
        end

        chunks.each_with_object(variants) do |ch, acc|
          acc[Multiset.new(ch.parents)] = ch unless ch.parents.empty?
        end
      end

      # Extends variants by independent chunks which could be in some of passed chunks
      # @param [Hash] variants is the extending value
      # @param [Array] chunks the list with potencial splitting chunk
      # @return [Hash] the map of extended variants
      def extend_variants(variants, chunks)
        collected_independent = []
        chunks.each_with_object(variants) do |chunk, acc|
          independent_chunks = split_to_independent_chunks(chunk)

          unique_independent = independent_chunks.map do |new_chunk|
            prev_chunk = collected_independent.find { |ci| ci.same?(new_chunk) }
            if prev_chunk
              prev_chunk
            else
              collected_independent << new_chunk
              new_chunk
            end
          end

          merging_chunks = independent_chunks.select do |ch|
            chunks.any? { |big_chunk| mergeable?([big_chunk, ch]) }
          end

          if merging_chunks.size > 0
            acc[Multiset.new(unique_independent)] = chunk
            unique_independent.each do |ch|
              chunk.store_parent(ch)
              acc[Multiset[ch]] = ch
            end
          end
        end
      end

      # Finds all possible combinations chunks
      # @param [Hash] variants the initial variants hash
      # @return [Hash] the full variants hash
      def recombine_variants(variants)
        presented_cmbs = variants.keys
        until presented_cmbs.empty?
          first = presented_cmbs.first
          extended_cmbs = presented_cmbs.map { |cmb| cmb + first }
          new_cmbs = extended_cmbs.reject { |cmb| variants.include?(cmb) }
          new_cmbs.each do |cmb|
            arr = cmb.to_a
            if mergeable?(arr)
              presented_cmbs << cmb
              value = DerivativeChunk.new(@typical_reaction, arr, variants)
              variants = update_variants_to_best(variants, cmb, value)
            else
              variants[cmb] = false
            end
          end

          presented_cmbs.shift # delete first chunk
        end
        variants
      end

      # Updates passed variants by select same derivative chunk with maximal parent
      # chunks and updates all same others to false value
      #
      # @param [Hash] variants which will be updated
      # @param [Multimap] cmb the chunks combinations
      # @param [DerivativeChunk] value which will be compared with all derivative
      #   chunks
      # @return [Hash] the updated variants (but original variants hash updates too)
      def update_variants_to_best(variants, cmb, value)
        sames = variants.select { |_, v| v && value.same?(v) }.to_a + [[cmb, value]]
        best = select_best(sames)
        (sames - [best]).each { |k, _| variants[k] = false }
        variants[best.first] = best.last unless variants.key?(best.first)
        variants
      end

      # Selects best pair where key is multiset of chunks and value is their
      # composition
      #
      # @param [Array] sames the list of pairs
      # @return [Array] the pair of best multiset and composition chunk
      def select_best(sames)
        with_original = sames.select { |k, _| k.any?(&:original?) }
        if with_original.empty?
          sames.max_by { |k, _| k.size }
        else
          maximal = with_original.max_by { |k, _| k.select(&:original?).max }
          parents = maximal.first.to_a.reduce([]) do |acc, chunk|
            acc + (chunk.parents.empty? ? [chunk] : chunk.parents)
          end

          mprs = Multiset.new(parents)
          with_original.find { |k, _| k == mprs } || maximal
        end
      end

      # Gets lists of common targets
      # @param [Array] targets the lists of targets for which the common targets will
      #   be selected
      # @return [Array] the lists of common targets
      def common_targets(targets)
        targets.combination(2).flat_map(&method(:select_commons)).uniq
      end

      # Selects common targets from both of passed lists
      # @param [Array] ts1 the first list of targets
      # @param [Array] ts2 the second list of targets
      # @return [Array] the array of common targets
      def select_commons(targets)
        ts1, ts2 = targets.map(&:to_a).map(&:dup)
        ts1.each_with_object([]) do |target, result|
          result << target if ts2.delete_one { |t| same_sa?(target, t) }
        end
      end

      # Gets the list targets of reaction
      # @return [Array] the list of targets of general reaction
      def general_targets
        @_general_targets ||= @typical_reaction.reaction.links.keys
      end

      # Checks that usages of each target from passed list is less than usaged in
      # general targets list
      #
      # @param [Array] targets each item usages of which will be checked
      # @return [Boolean] is usage of each target from passed list less than usages in
      #   general targets list or not
      def reject_less_used(targets)
        targets.reject do |target|
          cf = -> t { same_sa?(target, t) }
          targets.count(&cf) < general_targets.count(&cf)
        end
      end

      # Finds correspond relations of target in graph
      # @param [Hash] graph which the relations will be found
      # @param [Array] target for which the relations will be found
      # @param [Array] the list of relations or empty array
      def rels(graph, target)
        result = graph.find { |k, _| same_sa?(target, k) }
        result ? result.last : []
      end

      # Counts links of target in passed graph
      # @param [Hash] graph in which links will be counted
      # @param [Array] target which links will be counted
      # @return [Hash] the hash of counted links where keys are hash with face and
      #   direction and values are quantities of correspond relations
      def count_links(graph, target)
        groups = rels(graph, target).map(&:last).group_by(&:params)
        groups.each_with_object({}) { |(k, vs), acc| acc[k] = vs.size }
      end

      # Counts links of target in reaction graph
      # @param [Array] target for which the links will be counted
      # @return [Hash] the counting result
      def count_reaction_links(target)
        count_links(@typical_reaction.reaction.links, target)
      end

      # Counts links of target in chunk graph
      # @param [Array] target for which the links will be counted
      # @return [Hash] the counting result
      def count_chunk_links(chunk, target)
        count_links(chunk.links, target)
      end

      # Counts sums of target links using in all chunks
      # @param [Array] chunks list for each item of which the links will be counted
      #   and summarized then
      # @param [Array] target for which the total counting hash will be gotten
      # @return [Hash] the total counting hash of target relations
      def total_counts(chunks, target)
        chunks.each_with_object(count_reaction_links(target)) do |chunk, acc|
          count_chunk_links(chunk, target).each do |rp, n|
            acc[rp] ||= 0
            acc[rp] += n
          end
        end
      end

      # Check that all usage limits less or equal to atom relations limits
      # @param [Hash] usage_limits the limits which gotten by counting liks of target
      # @param [Hash] real_limits the limits of target atom relations
      # @return [Boolean] is any usage limit more than real limit or not
      def over_limits?(usage_limits, real_limits)
        usage_limits.any? { |rp, n| n > real_limits[rp] }
      end

      # Tries to merge passed chunks
      # @param [Array] chunks the list of chunks which tries to merge
      # @return [Boolean] is possible merge or not
      def mergeable?(chunks)
        targets = common_targets(chunks.map(&:targets))
        return true if targets.empty?

        full_used_targets = reject_less_used(targets)
        return true if full_used_targets.empty?

        full_used_targets.all? do |target|
          !over_limits?(total_counts(chunks, target), target.last.relations_limits)
        end
      end

      # Tries to merge chunk with itself
      # @param [Chunk] chunk which will be checked
      # @return [Array] the array of independen chunk if them are take a place
      def split_to_independent_chunks(chunk)
        links = chunk.links
        target_specs = chunk.target_specs
        specs = independen_sidepiece_specs(links, target_specs, chunk.sidepiece_specs)

        if specs.size > 1
          specs.map do |sidepiece_spec|
            ext_links = extract_links(links, target_specs, sidepiece_spec)
            used_targets = ext_links.keys.select do |target|
              target_specs.include?(target.first)
            end
            IndependentChunk.new(chunk, used_targets.to_set, ext_links)
          end
        else
          []
        end
      end

      # Gets sidepiece species which have relations just with target species
      # @param [Hash] links where the independent sidepiece species will be found
      # @param [Set] target_specs which are reactants
      # @param [Set] sidepiece_specs which are not reactants
      # @return [Array] the list of independent sidepiece specs
      def independen_sidepiece_specs(links, target_specs, sidepiece_specs)
        sidepiece_specs.select do |spec|
          rels_list = links.each_with_object([]) do |((s, _), rels), acc|
            acc << rels if spec == s
          end

          rels_list.all? do |rels|
            rels.all? { |(s, _), _| spec == s || target_specs.include?(s) }
          end
        end
      end

      # Extracts all links where passed spec uses
      # @param [Hash] links which will be observed
      # @param [Set] target_specs the reactants
      # @param [Concepts::Spec | Concepts::SpecificSpec] sidepiece_spec for which the
      #   links will be extracted
      # @return [Hash] the extracted links
      def extract_links(links, target_specs, sidepiece_spec)
        select_spec_lambda = -> spec do
          spec == sidepiece_spec || target_specs.include?(spec)
        end

        links.each_with_object({}) do |(spec_atom, rels), acc|
          spec = spec_atom.first
          if select_spec_lambda[spec]
            extra_rels = rels.select { |(s, _), _| select_spec_lambda[s] }
            acc[spec_atom] = extra_rels unless extra_rels.empty?
          end
        end
      end
    end

  end
end
