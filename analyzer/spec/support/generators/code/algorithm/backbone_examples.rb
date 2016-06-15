module VersatileDiamond
  module Generators
    module Code
      module Algorithm
        module Support

          module BackboneExamples
            shared_examples_for :check_entry_nodes do
              it 'atoms of nodes' do
                keyname_lists = backbone.entry_nodes.map(&method(:grep_keynames))
                expect(keyname_lists).to eq(points_list)
              end
            end

            shared_examples_for :check_action_nodes do
              it { expect(grep_keynames(backbone.action_nodes)).to eq(atoms_lists) }
            end

            shared_examples_for :check_finite_graph do
              it { expect(backbone.big_graph).to be_a(Hash) }
              it 'translate to atomic graph and check' do
                keyname_graph = translate_to_keyname_graph(backbone.final_graph)
                expect(keyname_graph).to match_graph(final_graph)
              end
            end

            shared_examples_for :check_ordered_graph do
              it 'translate to atomic graph and check' do
                entry =
                  if backbone.entry_nodes.size == 1
                    backbone.entry_nodes.first
                  else
                    entry_node
                  end

                original_ordered_graph = backbone.ordered_graph_from(entry)
                keyname_list = translate_to_keyname_list(original_ordered_graph)
                expect(keyname_list).to eq(ordered_graph)
              end
            end
          end

        end
      end
    end
  end
end
