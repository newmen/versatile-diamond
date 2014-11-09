module VersatileDiamond
  module Generators
    module Code
      module Algorithm
        module Support

          module BackboneExamples
            shared_examples_for :check_finite_graph do
              it 'translate to atomic graph and check' do
                atomic_graph = translate_to_atomic_graph(backbone.final_graph)
                expect(atomic_graph).to match_graph(final_graph)
              end
            end

            shared_examples_for :check_ordered_graph do
              it 'translate to atomic graph and check' do
                astns = anchors.each_with_object({}) do |a, acc|
                  backbone.final_graph.keys.each do |ns|
                    ns.each { |n| acc[a] ||= n if n.atom == a }
                    break if acc[a]
                  end
                end

                original_ordered_graph = backbone.ordered_graph_from(astns.values)
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
