module VersatileDiamond
  using Patches::RichArray

  module Organizers

    # Tries to combine several chunks for gets new children of wrapped dependent
    # typical rection
    class ChunksCombiner
      include Mcs::SpecsAtomsComparator
      include Modules::ListsComparer

      # Initializes combiner by target typical reaction
      # @param [DependentTypicalReaction] reaction for which new lateral reactions
      #   will be found (or not)
      def initialize(reaction)
        @reaction = reaction
        @variants = collect_variants

        @_children_chunks, @_general_targets = nil
      end

      # Combines children lateral raection chunks and produce new lateral reactions
      # @return [Array] the list of combined lateral reactions
      def combine
        @variants = recombine_variants(@variants)
      end

    private

      # Collects variants from children chunks
      # @return [Hash] the initial hash of combination variants
      def collect_variants
        vars = Hash[children_chunks.map { |ch| [Multiset[ch], nil] }]
        dependent_chunks = children_chunks.reject { |ch| ch.parents.emtpy? }
        dependent_vars = dependent_chunks.map { |ch| [Multiset.new(ch.parents), ch] }
        dependent_vars = Hash[dependent_vars]
        vars.merge!(dependent_vars)
      end

      # Gets all chunks from all possible children lateral reactions
      # @return [Array] the list of children chunks
      def children_chunks
        return @_children_chunks if @_children_chunks

        visited_children = Set.new
        all_children = @reaction.children.dup

        until all_children.empty?
          child = all_children.pop
          next if visited_children.include?(child)
          visited_children << child
          next if child.children.empty?
          all_children = (child.children + all_children).uniq
        end

        @_children_chunks = visited_children.map(&:chunk)
      end

      # Finds all possible combinations chunks
      # @param [Hash] vars the initial variants hash
      # @return [Hash] the full variants hash
      def recombine_variants(vars)
        vars = vars.dup
        iterable_chunks = vars.keys # keys is dupped array of chunks
        until iterable_chunks.empty?
          first = iterable_chunks.first
          first = vars[first] || first

          iterable_chunks.dup.each do |ch|
            cmb = first + (vars[ch] || ch)
            next if vars.include?(cmb)
            arr = cmb.to_a
            value = mergeable?(arr) ? DerivativeChunk.new(@reaction, arr) : nil
            vars[cmb] = value
            iterable_chunks << value if value
          end

          iterable_chunks.unshift # delete first chunk
        end
        vars
      end

      # Gets lists of common targets
      # @param [Array] targets the lists of targets for which the common targets will
      #   be selected
      # @return [Array] the lists of common targets
      def common_targets(targets)
        targets = targets.dup
        result = targets.pop
        until targets.empty?
          list = targets.pop
          result = select_commons(result, list)
        end
        result
      end

      # Selects common targets from both of passed lists
      # @param [Array] ts1 the first list of targets
      # @param [Array] ts2 the second list of targets
      # @return [Array] the array of common targets
      def select_commons(*targets)
        ts1, ts2 = targets.map(&:to_a).map(&:dup)
        ts1.each_with_object([]) do |target, result|
          result << target if ts2.delete_one { |t| same_sa?(target, t) }
        end
      end

      # Gets the list targets of reaction
      # @return [Array] the list of targets of general reaction
      def general_targets
        @_general_targets ||= @reaction.reaction.links.keys
      end

      # Checks that usages of each target from passed list is less than usaged in
      # general targets list
      #
      # @param [Array] targets each item usages of which will be checked
      # @return [Boolean] is usage of each target from passed list less than usages in
      #   general targets list or not
      def reject_less_used(targets)
        # TODO: targets could be similar
        targets.reject do |target|
          cf = -> t { same_sa?(target, t) }
          targets.count(&cf) < general_targets.count(&cf)
        end
      end

      # Counts links of target in passed graph
      # @param [Hash] graph in which links will be counted
      # @param [Array] target which links will be counted
      # @return [Hash] the hash of counted links where keys are hash with face and
      #   direction and values are quantities of correspond relations
      def count_links(graph, target)
        groups = graph[target].map(&:last).group_by(&:params)
        groups.each_with_object({}) { |(k, vs), acc| acc[k] = vs.size }
      end

      # Counts links of target in reaction graph
      # @param [Array] target for which the links will be counted
      # @return [Hash] the counting result
      def count_reaction_links(target)
        count_links(@reaction.reaction.links, target)
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
    end

  end
end
