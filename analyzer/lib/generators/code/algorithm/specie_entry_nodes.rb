module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Provides logic for selecting entry nodes of find specie algorithm
        class SpecieEntryNodes
          class << self
            # Sorts passed nodes lists by next algorithm: the bigger size lists places
            # to begin, if sizes of ordering lists are equal then list with nodes which
            # has bigger atom properties then it places to begin
            #
            # @param [Array] lists_of_nodes which will be ordered
            # @return [Array] the specific ordered list of lists
            def sort(lists_of_nodes)
              lists_of_nodes.sort do |as, bs|
                az, bz = as.size, bs.size
                if az == bz
                  as.zip(bs).reduce(0) do |acc, ns|
                    acc == 0 ? forward_not_anchors(*ns) : acc
                  end
                else
                  bz <=> az
                end
              end
            end

          private

            # Compares passed passed nodes so anchors places to end
            # @param [SpecieNode] a
            # @param [SpecieNode] b
            # @param [Integer] comparation result
            def forward_not_anchors(a, b)
              if a.anchor? == b.anchor?
                a <=> b
              else
                !a.anchor? && b.anchor? ? -1 : 1
              end
            end
          end

          # Initializes entry nodes detector by specie
          # @param [Hash] the final grouped (backbone) graph of find algorithm
          def initialize(final_graph)
            @grouped_nodes = final_graph
            @nodes = @grouped_nodes.keys.flatten.uniq.sort

            @_list = nil
          end

          # Gets entry nodes of find algorithm
          # @return [Array] the ordered entry nodes, each item is array of nodes
          def list
            return @_list if @_list

            @_list =
              if @nodes.all?(&:none?) || @nodes.uniq(&:uniq_specie).one?
                [@nodes]
              else
                # finds first because nodes are sorted ^^
                limited_nodes = @nodes.select(&method(:extra_limited?))
                if limited_nodes.empty?
                  most_important_nodes
                else
                  limited_nodes.map { |node| [node] }
                end
              end
          end

        private

          # Checks that scoped node is limited by number of bonds or unique properties
          # @param [SpecieNode] node which will be checked
          # @return [Boolean] is limited or not
          def extra_limited?(node)
            node.anchor? && node.scope? && (node.limited? || !avail_more?(node))
          end

          # Checks that avail another node which includes the passed
          # @param [SpecieNode] node which will be checked
          # @return [Boolean] is there another node which includes the passed or not
          def avail_more?(node)
            @nodes.any? { |n| n != node && n.properties.include?(node.properties) }
          end

          # Selects the maximal useful node from passed group
          # @param [Array] group of similar nodes
          # @param [Array] anchor_nodes the list of anchored nodes
          # @return [Nodes::SpecieNode]
          def best_node_in(group, anchor_nodes)
            same_times_used = group.group_by(&anchor_nodes.public_method(:count))
            best_nodes = same_times_used.max_by(&:first).last
            best_nodes.find { |node| @grouped_nodes[[node]] } ||
              best_nodes.find do |node|
                @grouped_nodes.keys.any? { |ns| ns.include?(node) }
              end
          end

          # Gets the list of anchor nodes from which the search can be occured
          # @return [Array] the list of anchor nodes
          def major_anchor_nodes
            real_nodes = @nodes.reject(&:none?).select(&:actual_anchor?)
            uniq_species = real_nodes.map(&:uniq_specie).uniq
            if real_nodes.size == uniq_species.size
              real_nodes
            else
              real_nodes.select(&:anchor?)
            end
          end

          # Selects the nodes which are mostly used as keys of grouped nodes graph
          # @return [Array] the array of most used nodes
          def most_used_nodes
            anchor_nodes = major_anchor_nodes
            if anchor_nodes.empty?
              raise 'Anchor nodes not found'
            else
              groups = anchor_nodes.groups { |n| [orig_species_from(n), n.properties] }
              # selects the best from each group
              groups.map { |group| best_node_in(group, anchor_nodes) }.uniq
            end
          end

          # Selects the most important nodes in keys of grouped nodes graph
          # @return [Array] the ordered most different or binding nodes
          def most_important_nodes
            self.class.sort(target_groups.uniq { |ns| ns.map(&:properties).to_set })
          end

          # Gets nodes which grouped by using in parent specie and each group contains
          # nodes at the limit of specie or unique set of using atom properties
          #
          # @return [Array] the nodes grouped by special algorithm
          def target_groups
            most_used_nodes.groups(&:uniq_specie).map do |group|
              border_nodes = select_border(group)
              border_nodes.empty? ? group.uniq(&:properties) : border_nodes
            end
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

          # Gets set of original species from node
          # @param [SpecieNode] node from whic species will be gotten
          # @return [Set] the set of original species
          def orig_species_from(node)
            if node.scope?
              node.uniq_specie.species.map(&:original).to_set
            else
              Set[node.uniq_specie.original]
            end
          end
        end

      end
    end
  end
end
