require 'rspec/expectations'

module VersatileDiamond
  using Patches::RichArray

  module Support
    module Matchers
      include VersatileDiamond::Modules::ListsComparer

      RSpec::Matchers.define :match_graph do |expected|
        match do |actual|
          actual_keys, expected_keys = actual.keys, expected.keys
          if homogeneous?(actual) && multidim_keys?(actual_keys, expected_keys)
            keys_cmpr = method(:identical_multidim_keys?)
            lists_are_identical?(actual_keys, expected_keys, &keys_cmpr) &&
              actual.all? do |key, rels|
                expected_key, expected_rels = key_with_rels_for(expected, key)
                rels_cmpr = rels_cmpr_provider(key, expected_key)
                lists_are_identical?(rels, expected_rels, &rels_cmpr)
              end
          else
            lists_are_identical?(actual_keys, expected_keys, &:==) &&
              actual.all? do |key, rels|
                lists_are_identical?(rels, expected[key], &:==)
              end
          end
        end

        failure_message do |actual|
          excess = graphs_diff(actual, expected)
          missed = graphs_diff(expected, actual)

          strs = [
            "expected that\n#{graph_to_s(actual)}",
            "should be like\n#{graph_to_s(expected)}",
          ]
          strs << "excess:\n#{graph_to_s(excess)}" unless excess.empty?
          strs << "missed:\n#{graph_to_s(missed)}" unless missed.empty?

          strs.join("\n")
        end

        # Transforms graph to string
        # @param [Hash] graph the transforming graph
        # @return [String] the multiline string
        def graph_to_s(graph)
          lines = graph.map { |key, rels| "    #{key.inspect} => #{rels.inspect}" }
          lines.join("\n")
        end

        # Selects difference between two graphs
        # @param [Hash] actual received graph
        # @param [Hash] expected graph
        # @return [Hash] the difference between two graphs
        def graphs_diff(actual, expected)
          if homogeneous?(actual) && multidim_keys?(actual.keys, expected.keys)
            actual.each_with_object({}) do |(v, rels), acc|
              expected_key, expected_rels = key_with_rels_for(expected, v)
              rels_cmpr = rels_cmpr_provider(v, expected_key)

              next if !expected_key.empty? &&
                lists_are_identical?(rels, expected_rels, &rels_cmpr)

              if expected_key.empty?
                ed, rd = expected_rels.dup, rels.dup
                rd.delete_one { |k| rels_cmpr[k, ed.pop] } until ed.empty? || rd.empty?
                acc[v] = rd unless rd.empty?
              else
                acc[v] = rels
              end
            end
          else
            actual.each_with_object({}) do |(v, rels), acc|
              next if expected[v] && lists_are_identical?(rels, expected[v], &:==)
              if expected[v]
                ed, rd = expected[v].dup, rels.dup
                rd.delete_one(ed.pop) until ed.empty? || rd.empty?
                acc[v] = rd unless rd.empty?
              else
                acc[v] = rels
              end
            end
          end
        end

        # Gets a key with corresponding relations from passed graph by same key
        # @param [Hash] graph from which the pair will be gotten
        # @param [Array] key for which the same key in passed graph will be found
        # @return [Array] the pair of found same key and it relations
        def key_with_rels_for(graph, key)
          key_with_rels = graph.find { |k, rels| identical_multidim_keys?(k, key) }
          key_with_rels || [[], []]
        end

        # Checks that passed graph is homogeneous
        # @param [Hash] graph which will be checked
        # @return [Boolean] is homogeneous graph or not
        def homogeneous?(graph)
          if multidim_key?(graph.keys.first)
            graph.all? do |key, rels|
              uniform?(key) && rels.all? { |k, _| uniform?(k) }
            end
          else
            true
          end
        end

        # Checks that passed multi-dimensional key is uniform
        # @param [Array] key which will be checked
        # @return [Boolean] is uniform multi-dimensional key or not
        def uniform?(key)
          key.map(&:class).all_equal?
        end

        # Checks that passed key is multi-dimensional
        # @param [Object] key which will be checked
        # @return [Boolean] is multi-dimensional key or not
        def multidim_key?(key)
          key.is_a?(Array)
        end

        # Checks that both passed lists are multi-dimensional
        # @param [Array] keys1 the first checking list
        # @param [Array] keys2 the second checking list
        # @return [Boolean] are both lists multi-dimensional or not
        def multidim_keys?(keys1, keys2)
          is_array_proc = method(:multidim_key?)
          keys1.all?(&is_array_proc) && keys2.all?(&is_array_proc)
        end

        # Compares multi-dimensional keys lists
        # @param [Array] keys1 the first comparing list
        # @param [Array] keys2 the second comparing list
        # @return [Boolean] are identical lists or not
        def identical_multidim_keys?(keys1, keys2)
          lists_are_identical?(keys1, keys2, &:==)
        end

        # Provides lambda function for compare relations of passed keys
        # @param [Array] act_k the key from actual graph which dictates the order
        # @param [Array] exp_k the key which will reordered if it need
        # @return [Proc] the function which will used for compare relations of both
        #   graphs
        def rels_cmpr_provider(act_k, exp_k)
          -> rel1, rel2 do
            rel1.last == rel2.last &&
              if rel1.size == act_k.size
                rel1.first == indexes_seq(act_k, exp_k).map { |i| rel2.first[i] }
              else
                identical_multidim_keys?(rel1.first, rel2.first)
              end
          end
        end

        # Gets correct sequence of indexes by which expected keys will reordered
        # @param [Array] key from actual graph which dictates the order
        # @param [Array] expected_key which will reordered if it need
        # @return [Array] the sequence of indexes
        def indexes_seq(key, expected_key)
          expected_key_dup = expected_key.dup
          key.map.with_index do |k, i|
            ei = expected_key_dup.index { |ek| ek == k }
            expected_key_dup[ei] = :NO_VALUE_CAP
            ei
          end
        end
      end

      RSpec::Matchers.define :match_multidim_array do |expected|
        match do |actual|
          lists_are_identical?(actual, expected) do |a, b|
            lists_are_identical?(a, b, &:==)
          end
        end

        failure_message do |actual|
          "expected that\n#{multidim_array_to_s(actual)}\n" \
            "should be like\n#{multidim_array_to_s(expected)}"
        end

        # Transforms matrix to string
        # @param [Hash] matrix the transforming matrix
        # @return [String] the multiline string
        def multidim_array_to_s(matrix)
          lines = matrix.map { |values| "    #{values.inspect}" }
          content = lines.join("\n")
          "[\n#{content}\n]"
        end
      end

    end
  end
end
