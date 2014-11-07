module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides logic for selecting entry nodes of find specie algorithm
        class EntryNodes

          # Initializes entry nodes detector by specie
          # @param [SpecieBackbone] the backbone of find algorithm
          def initialize(backbone)
            @grouped_nodes = backbone.final_graph
          end

          # Gets entry nodes of find algorithm
          # @return [Array] the ordered entry nodes, each item is array of nodes
          def list
            nodes = @grouped_nodes.keys.flatten.uniq.sort
            if nodes.all?(&:none?) || nodes.uniq(&:uniq_specie).size == 1
              [nodes]
            elsif nodes.any?(&:scope?)
              [[nodes.find(&:scope?)]] # finds first because nodes are sorted ^^
            else
              select_most_important(nodes)
            end
          end

        private

          # Selects the most important nodes in passed nodes set
          # @param [Array] nodes from which the most important nodes will be found
          # @return [Array] the most different or binding nodes
          def select_most_important(nodes)
            groups = nodes.reject(&:none?).group_by(&:uniq_specie).values
            target_groups = groups.map do |group|
              border_nodes = select_border(group)
              border_nodes.empty? ? group.uniq(&:properties) : border_nodes
            end

            target_groups.uniq { |ns| ns.map(&:properties).to_set }
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
        end

      end
    end
  end
end
