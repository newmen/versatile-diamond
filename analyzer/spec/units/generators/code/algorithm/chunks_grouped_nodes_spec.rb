require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ChunksGroupedNodes, type: :algorithm do
          let(:grouped_nodes) { described_class.new(generator, reaction) }
          let(:reaction) { generator.reaction_class(dependent_typical_reaction.name) }
          let(:generator) do
            stub_generator(
              typical_reactions: [dependent_typical_reaction],
              lateral_reactions: chunks.map(&:lateral_reaction)
            )
          end

          let(:big_links_method) { :links }
          def node_to_vertex(node); [node.dept_spec.spec, node.atom] end

          it_behaves_like :check_grouped_nodes_graph do
            let(:dependent_typical_reaction) { dept_dimer_formation }
            let(:chunks) { [end_chunk] }

            let(:b1) { df_source.first.atom(:ct) }
            let(:b2) { df_source.last.atom(:ct) }

            let(:lateral_dimer) { dimer }
            let(:d1) { lateral_dimer.atom(:cr) }
            let(:d2) { lateral_dimer.atom(:cl) }

            let(:flatten_face_grouped_atoms) { [[a1, a2]] }
            let(:nodes_list) do
              [
                [UniqueSpecie, a1],
                [UniqueSpecie, a2]
              ]
            end
            let(:grouped_graph) do
              {
                [a1] => [[[a2], param_100_front]],
                [a2] => [[[a1], param_100_front]]
              }
            end
          end
        end

      end
    end
  end
end
