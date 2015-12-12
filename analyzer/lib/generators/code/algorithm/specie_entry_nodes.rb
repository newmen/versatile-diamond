module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Provides logic for selecting entry nodes of find specie algorithm
        class SpecieEntryNodes

          # Initializes entry nodes detector by specie
          # @param [Hash] the final grouped (backbone) graph of find algorithm
          def initialize(final_graph)
            @grouped_nodes = final_graph
            @_list = nil
          end

          # Gets entry nodes of find algorithm
          # @return [Array] the ordered entry nodes, each item is array of nodes
          def list
            @_list ||=
              nodes = @grouped_nodes.keys.flatten.uniq.sort
              if nodes.all?(&:none?) || nodes.uniq(&:uniq_specie).size == 1
                [nodes]
              elsif nodes.any?(&:scope?)
                [[nodes.find(&:scope?)]] # finds first because nodes are sorted ^^
              else
                most_important_nodes.map(&:sort)
              end
          end

        private

          # Selects the nodes which are mostly used as keys of grouped nodes graph
          # @return [Array] the array of most used nodes
          def most_used_nodes
            all_nodes = @grouped_nodes.keys.flatten.reject(&:none?)
            groups = all_nodes.groups { |n| [n.uniq_specie.original, n.properties] }
            most_used = groups.reduce([]) do |acc, group|
              acc << group.max_by { |n| all_nodes.count(n) }
            end
            most_used.uniq
          end

          # Selects the most important nodes in keys of grouped nodes graph
          # @return [Array] the ordered most different or binding nodes
          def most_important_nodes
            target_groups = most_used_nodes.groups(&:uniq_specie).map do |group|
              border_nodes = select_border(group)
              border_nodes.empty? ? group.uniq(&:properties) : border_nodes
            end

            sort_by_sizes(target_groups.uniq { |ns| ns.map(&:properties).to_set })
          end

          # Selects nodes which have placed at border of analyzing specie
          # @param [Array] nodes from which the border nodes will be found
          # @return [Array] the nodes which have NoneSpec neighbour node(s)
          def select_border(nodes)
            nodes.select do |node|
              @grouped_nodes.any? do |ns, rels|
                idx = ns.index(node)
                idx && rels.any? { |nbrs, _| nbrs[idx].none? }
              end
            end
          end

          # Sorts passed nodes lists by next algorithm: the bigger size lists places to
          # begin, if sizes of ordering lists are equal then list with nodes which has
          # bigger atom properties then it places to begin
          #
          # @param [Array] nodes_lists the list of lists of nodes which will be ordered
          # @return [Array] the specific ordered list of lists
          def sort_by_sizes(nodes_lists)
            nodes_lists.sort do |as, bs|
              az, bz = as.size, bs.size
              if az == bz
                as.zip(bs).reduce(0) { |acc, (a, b)| acc == 0 ? a <=> b : acc }
              else
                bz <=> az
              end
            end
          end
        end

      end
    end
  end
end
