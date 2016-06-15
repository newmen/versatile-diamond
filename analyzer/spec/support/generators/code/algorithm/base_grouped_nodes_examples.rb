module VersatileDiamond
  module Generators
    module Code
      module Algorithm
        module Support

          module BaseGroupedNodesExamples
            shared_examples_for :check_grouped_nodes_graph do
              # each method should not change the state of grouped nodes graph
              it 'all public methods' do
                big_atomic =
                  grouped_nodes.big_graph.each_with_object({}) do |(node, rels), acc|
                    acc[node_to_vertex(node)] = rels.map do |n, r|
                      [node_to_vertex(n), r]
                    end
                  end
                expect(big_atomic).to eq(subject.public_send(big_links_method))

                anchor_nodes = grouped_nodes.flatten_face_grouped_nodes
                anchor_kns = anchor_nodes.map(&method(:grep_keynames))
                expect(anchor_kns).to match_multidim_array(flatten_face_grouped_atoms)

                typed_nodes = typed_nodes_list(grouped_nodes.final_graph)
                expect(typed_nodes).to match_array(nodes_list)

                keyname_graph = translate_to_keyname_graph(grouped_nodes.final_graph)
                expect(keyname_graph).to match_graph(grouped_graph)
              end
            end
          end

        end
      end
    end
  end
end
