require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe LateralChunksGroupedNodes, type: :algorithm do
          let(:generator) do
            stub_generator(
              typical_reactions: [typical_reaction],
              lateral_reactions: lateral_reactions
            )
          end
          let(:reaction) { generator.reaction_class(typical_reaction.name) }
          let(:chunks) { lateral_reactions.map(&:chunk) }
          let(:grouped_nodes) { described_class.new(generator, subject) }
          let(:sidepiece_specs) { subject.sidepiece_specs.to_a }
          subject { reaction.lateral_chunks }

          let(:big_links_method) { :links }
          def node_to_vertex(node); [node.dept_spec.spec, node.atom] end

          let(:typical_reaction) { dept_dimer_formation }
          let(:t1) { df_source.first.atom(:ct) }
          let(:t2) { df_source.last.atom(:ct) }

          let(:lateral_dimer) do
            sidepiece_specs.select { |spec| spec.name == :dimer }.first
          end
          let(:d1) { lateral_dimer.atom(:cr) }
          let(:d2) { lateral_dimer.atom(:cl) }

          describe 'just cross neighbours' do
            let(:flatten_face_grouped_atoms) { [[t1, t2], [d1, d2]] }
            let(:nodes_list) do
              [
                [UniqueSpecie, t1],
                [UniqueSpecie, t2],
                [UniqueSpecie, d1],
                [UniqueSpecie, d2]
              ]
            end

            let(:grouped_graph) do
              {
                [t1, t2] => [[[d2, d1], param_100_cross]],
                [d1, d2] => [[[t2, t1], param_100_cross]]
              }
            end

            it_behaves_like :check_grouped_nodes_graph do
              let(:lateral_reactions) { [dept_end_lateral_df] }
            end

            it_behaves_like :check_grouped_nodes_graph do
              let(:lateral_reactions) { [dept_middle_lateral_df] }
            end

            it_behaves_like :check_grouped_nodes_graph do
              let(:lateral_reactions) do
                [dept_end_lateral_df, dept_middle_lateral_df]
              end
            end
          end

          describe 'not only cross neighbours' do
            let(:lateral_bridge) { (sidepiece_specs - [lateral_dimer]).first }
            let(:b) { lateral_bridge.atom(:ct) }

            let(:nodes_list) do
              [
                [UniqueSpecie, t1],
                [UniqueSpecie, t2],
                [UniqueSpecie, d1],
                [UniqueSpecie, d2],
                [UniqueSpecie, b]
              ]
            end

            let(:flatten_face_grouped_atoms) do
              [[t1, t2], [d1, d2], [b]]
            end

            describe 'first case' do
              let(:grouped_graph) do
                {
                  [t2, t1] => [[[d1, d2], param_100_cross]],
                  [d1, d2] => [[[t2, t1], param_100_cross]],
                  [t2] => [[[b], param_100_front]],
                  [b] => [[[t2], param_100_front]]
                }
              end

              it_behaves_like :check_grouped_nodes_graph do
                let(:lateral_reactions) { [dept_ewb_lateral_df] }
              end

              it_behaves_like :check_grouped_nodes_graph do
                let(:lateral_reactions) { [dept_mwb_lateral_df] }
              end

              it_behaves_like :check_grouped_nodes_graph do
                let(:lateral_reactions) do
                  [dept_mwb_lateral_df, dept_middle_lateral_df]
                end
              end
            end

            describe 'second case' do
              let(:grouped_graph) do
                {
                  [t2, t1] => [[[d1, d2], param_100_cross]],
                  [d2, d1] => [[[t1, t2], param_100_cross]],
                  [t2] => [[[b], param_100_front]],
                  [b] => [[[t2], param_100_front]]
                }
              end

              it_behaves_like :check_grouped_nodes_graph do
                let(:lateral_reactions) { [dept_ewb_lateral_df, dept_mwb_lateral_df] }
              end
            end
          end
        end

      end
    end
  end
end
