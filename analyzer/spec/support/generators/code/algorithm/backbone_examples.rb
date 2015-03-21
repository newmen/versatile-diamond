module VersatileDiamond
  module Generators
    module Code
      module Algorithm
        module Support

          module BackboneExamples
            shared_examples_for :check_entry_nodes do
              it 'atoms of nodes' do
                atoms_lists = backbone.entry_nodes.map(&method(:grub_atoms))
                expect(atoms_lists).to eq(points_list)
              end
            end

            shared_examples_for :check_finite_graph do
              it 'translate to atomic graph and check' do
                atomic_graph = translate_to_atomic_graph(backbone.final_graph)
                expect(atomic_graph).to match_graph(final_graph)
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
                atomic_list = translate_to_atomic_list(original_ordered_graph)
                expect(atomic_list).to eq(ordered_graph)
              end
            end
          end

        end
      end
    end
  end
end
