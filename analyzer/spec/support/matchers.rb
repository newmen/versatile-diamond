require 'rspec/expectations'

module VersatileDiamond
  using Patches::RichArray

  module Support
    module Matchers
      include VersatileDiamond::Modules::ListsComparer

      def graphs_diff(actual, expected)
        actual.each_with_object({}) do |(v, rels), acc|
          next if expected[v] && lists_are_identical?(expected[v], rels, &:==)
          if expected[v]
            ed, rd = expected[v].dup, rels.dup
            rd.delete_one(ed.pop) until ed.empty? || rd.empty?
            acc[v] = rd unless rd.empty?
          else
            acc[v] = rels
          end
        end
      end

      RSpec::Matchers.define :match_graph do |expected|
        match do |actual|
          lists_are_identical?(actual.keys, expected.keys, &:==) &&
            actual.all? do |key, values|
              lists_are_identical?(values, expected[key], &:==)
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
          lines = graph.map { |key, values| "    #{key.inspect} => #{values.inspect}" }
          lines.join("\n")
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
