module VersatileDiamond
  using Patches::RichArray

  module Organizers

    # Tries to combine several chunks for gets new children of wrapped dependent
    # typical rection
    class ChunksCombiner
      include Mcs::SpecsAtomsComparator
      include Modules::ListsComparer
      include Modules::ExtendedCombinator

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
          chunk && !chunks.include?(chunk)
        end

        all_chunks = chunks + unregistered_chunks
        all_chunks.each { |ch| ch.remember_internal_chunks! }
        all_chunks.each { |ch| ch.reorganize_parents!(all_chunks) }
        unregistered_chunks.map(&:lateral_reaction)
      end

    private

      # Collects variants from passed chunks
      # @param [Array] chunks from which the variants will be collected
      # @return [Hash] the initial hash of combination variants
      def collect_variants(chunks)
        variants = Hash[chunks.map { |ch| [Multiset[ch], ch] }]
        extend_variants(variants, chunks)
      end

      # Extends variants by independent chunks which could be in some of passed chunks
      # @param [Hash] variants is the extending value
      # @param [Array] chunks the list with potencial splitting chunk
      # @return [Hash] the map of extended variants
      def extend_variants(variants, chunks)
        previous_collected = chunks.dup
        chunks.each_with_object(variants) do |chunk, acc|
          independent_chunks = split_to_independent_chunks(chunk)

          reused_independent = independent_chunks.map do |new_chunk|
            prev_chunk = previous_collected.find { |ci| ci.same?(new_chunk) }
            if prev_chunk
              prev_chunk
            else
              previous_collected << new_chunk
              new_chunk
            end
          end

          next if reused_independent.empty?

          total_key = Multiset.new(reused_independent)
          unless acc[total_key]
            acc[Multiset[chunk]] = false
            acc[total_key] = chunk
            reused_independent.each do |ch|
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
        presented_cmbs = variants.to_a.select(&:last).map(&:first)
        until presented_cmbs.empty?
          presented_cmbs = sort_cmbs(presented_cmbs)
          smallest = presented_cmbs.first
          extended_cmbs = presented_cmbs.map { |cmb| cmb + smallest }
          new_cmbs = extended_cmbs.reject { |cmb| variants.include?(cmb) }
          new_cmbs.each do |cmb|
            variants, chs = find_mergeable(variants, cmb)
            presented_cmbs << chs if chs
          end

          presented_cmbs.shift # delete first chunk
        end
        variants
      end

      # Finds mergeable chunks from passed combination
      # @param [Hash] variants of all found chunks
      # @param [Multiset] cmb the combination of merging chunks
      # @return [Array] the array where first item is updated variants and the second
      #   value is found chunks which merges successfully
      def find_mergeable(variants, cmb)
        chunks_mirror = mergeable(cmb.to_a)
        if chunks_mirror.empty?
          variants[cmb] = false
          [variants, nil]
        else
          chunks_mirror = chunks_mirror.reject(&:==)
          prs_chs = variants.values.uniq # presented chunks
          chunks = cmb.map do |ch|
            new_ch = chunks_mirror[ch]
            (new_ch && prs_chs.find { |prs_ch| prs_ch.accurate_same?(new_ch) }) || ch
          end

          variants[chunks] = MergedChunk.new(@typical_reaction, chunks.to_a, variants)
          [variants, chunks]
        end
      end

      # Sorts passed multisets
      # @param [Array] cmbs the list of combinations which will sorted by asc
      # @return [Array] sorted list of multisets combinations
      def sort_cmbs(cmbs)
        cmbs.sort do |*multisets|
          a, b = multisets.map { |ms| ms.map(&:total_links_num).reduce(:+) }
          if a == b
            x, y = multisets.map(&:size)
            x <=> y
          else
            a <=> b
          end
        end
      end

      # Gets lists of common targets
      # @param [Array] chunks the lists of chunks for which the common targets will
      #   be selected
      # @return [Array] the lists of common targets
      def common_targets(chunks)
        uniq_chunks = chunks.uniq
        if uniq_chunks.size == 1
          chunks.first.targets.to_a
        else
          similar = chunks.groups { |ch| ch }.select { |gr| gr.size > 1 }.map(&:first)
          targets = uniq_chunks.map(&:targets)
          common = targets.combination(2).flat_map(&method(:select_commons)).uniq
          (common + similar.flat_map { |ch| ch.targets.to_a }).uniq
        end
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

      # Finds correspond relations of target in graph
      # @param [Hash] graph which the relations will be found
      # @param [Array] target for which the relations will be found
      # @param [Array] the list of relations or empty array
      def rels_in(graph, target)
        graph[target] || []
      end

      # Counts links of target in passed graph
      # @param [Hash] graph in which links will be counted
      # @param [Array] target which links will be counted
      # @return [Hash] the hash of counted links where keys are hash with face and
      #   direction and values are quantities of correspond relations
      def count_links(graph, target)
        groups = rels_in(graph, target).map(&:last).group_by(&:params)
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

      # Verifies relations limits of target in reaction and chunks
      # @param [Array] chunks where relations of target will checked
      # @param [Array] target which relations will checked
      # @return [Boolean] is satisfactory limits or not
      def good_limits?(chunks, target)
        !over_limits?(total_counts(chunks, target), target.last.relations_limits)
      end

      # Tries to merge passed chunks and if it possible returns chunks which could be
      # merged
      #
      # @param [Array] chunks the list of chunks which tries to merge
      # @return [Array] the list of maps with merging chunks
      def mergeable(chunks)
        targets = common_targets(chunks)
        if targets.empty? || targets.all? { |target| good_limits?(chunks, target) }
          Hash[chunks.zip(chunks)]
        else
          cross_mergeable(chunks, targets)
        end
      end

      # Tries to merge chunks with similar targets
      # @param [Array] chunks where relations of targets will checked
      # @param [Array] targets which limits will checked
      # @return [Array] the list of maps with cross merging chunks
      def cross_mergeable(chunks, targets)
        all_groups = same_targets_groups(targets)
        sames_grs = all_groups.select { |gr| gr.size > 1 }
        uniqs = (all_groups - sames_grs).map(&:first)

        default_value = {}
        if !sames_grs.empty? && uniqs.all? { |target| good_limits?(chunks, target) }
          results = sames_grs.map { |group| similar_mergeable(chunks, group) }
          results.any?(&:empty?) ? default_value : concat_cross_mergiable(results)
        else
          default_value
        end
      end

      # Splits the list of targets to groups where each item is same as other
      # @param [Array] targets from which the similar will selected
      # @return [Array] the list of similar targets
      def same_targets_groups(targets)
        groups = []
        cheking_targets = (general_targets + targets).uniq
        iterating_chunks = cheking_targets.dup

        until iterating_chunks.empty? do
          target = iterating_chunks.pop
          next unless targets.include?(target)

          cheking_targets.delete_one(target)
          groups << cheking_targets.dup.reduce([target]) do |acc, t|
            if same_sa?(target, t)
              iterating_chunks.delete_one(t)
              acc << cheking_targets.delete_one(t)
            else
              acc
            end
          end
        end

        groups
      end

      # Concats all cross mergiable results
      # @param [Array] mergeable_list the list of all merging chunks with using targets
      # @return [Hash] the hash where keys are original chunks and values are chunks
      #   with replaced targets
      def concat_cross_mergiable(mergeable_lists)
        groups = group_cross_mergiable(mergeable_lists)
        old_new = groups.map do |chunk, targets_pairs|
          newch = targets_pairs.reduce(chunk) { |acc, pair| acc.replace_target(*pair) }
          [chunk, newch]
        end

        Hash[old_new]
      end

      # Groups cross mergiable results by chunks
      # @param [Array] mergeable_list the list of all merging chunks with using targets
      # @result [Hash] the hash where keys are original chunks and values are lists of
      #   pairs of replacing targets
      def group_cross_mergiable(mergeable_lists)
        mergeable_lists.reduce(:+).each_with_object({}) do |(ch, targets), acc|
          acc[ch] ||= []
          acc[ch] << targets
        end
      end

      # Verifies that same targets satisfy reaction and chunks relations limits
      # @param [Array] chunks where relations of targets will checked
      # @param [Array] same_targets which limits will checked
      # @return [Hash] the mirror of original chunks to chunks which can be merged
      def similar_mergeable(chunks, same_targets)
        iterate_permutations(chunks, same_targets) do
          result = targets_maps.zip(chunks_groups).map do |ts_map, cs_group|
            ts_map.reduce([]) do |acc, (k, v)|
              selected_chunks = cs_group.select { |ch| ch.targets.include?(k) }
              acc + map_chunks_to_targets(selected_chunks, k, v)
            end
          end

          result.any?(&:empty?) ? [] : purge_mapping_result(result)
        end
      end

      # Purges mapping result from not significant results
      # @param [Array] result which will be purged
      # @return [Array] flatten clear mapping result
      def purge_mapping_result(result)
        result.reduce(:+).reject { |_, (from, to)| from == to }
      end

      # Maps selected chunks to using targets
      # @param [Array] chunks which was selected
      # @param [Array] original_target which uses in chunks
      # @param [Array] same_target which should be used for merge chunks
      # @return [Array] list of mapped chunk to using targets
      def map_chunks_to_targets(chunks, original_target, same_target)
        if !chunks.empty? && good_limits?(chunks, same_target)
          chunks.map { |ch| [ch, [original_target, same_target]] }
        else
          []
        end
      end

      # Iterates permutations of chunks and targets for find mergeable chunks with
      # similar targets
      #
      # @param [Array] chunks where relations of targets will checked
      # @param [Array] same_targets which limits will checked
      # @yield [Array, Array] iterates groups of chunks and targets
      # @return [Hash] result of block execution if any of it is set
      def iterate_permutations(chunks, targets, &block)
        splitted_chunks_groups = possible_chunks_combinations(chunks)
        permutate_targets(targets).reduce([]) do |a1, targets_maps|
          !a1.empty? ? a1 : splitted_chunks_groups.reduce(a1) do |a2, chunks_groups|
            a2.empty? ? a2 + block[chunks_groups, targets_map] : a2
          end
        end
      end

      # Permutates passed targets
      # @param [Array] targets for which the permutation maps will gotten
      # @return [Array] the list of permutation maps
      def permutate_targets(targets)
        perms = targets.permutation.to_a
        perms.shift
        perms.map { |seq| [targets.zip(targets), targets.zip(seq)] }
      end

      # Gets the chunks combination groups where each group contains two subsets:
      # "selected" and "not selected" chunks
      #
      # @param [Array] chunks which will sliced to selected-unselected groups
      # @return [Array] the list of selected-unselected groups
      def possible_chunks_combinations(chunks)
        result = sliced_combinations(chunks, 1, chunks.size - 1).flat_map do |cmbs|
          cmbs.map do |cmb|
            chunks_dup = chunks.dup
            cmb.each { |ch| chunks_dup.delete_one(ch) }
            [cmb, chunks_dup]
          end
        end
        result.uniq
      end

      # Tries to merge chunk with itself
      # @param [Chunk] chunk which will be checked
      # @return [Array] the array of independentchunk if them are take a place
      def split_to_independent_chunks(chunk)
        links = chunk.links
        target_specs = chunk.target_specs
        specs = independent_sidepiece_specs(links, target_specs, chunk.sidepiece_specs)

        if specs.size > 1
          specs.map do |sidepiece_spec|
            ext_links = extract_links(links, target_specs, sidepiece_spec)
            used_targets = ext_links.keys.select do |target|
              target_specs.include?(target.first)
            end
            IndependentChunk.new(@typical_reaction, used_targets.to_set, ext_links)
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
      def independent_sidepiece_specs(links, target_specs, sidepiece_specs)
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
