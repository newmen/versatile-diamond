require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe LateralChunksGroupedNodes, type: :algorithm, use: :chunks do
          let(:grouped_nodes) { described_class.new(generator, lateral_chunks) }
          subject { lateral_chunks }

          let(:big_links_method) { :links }
          def node_to_vertex(node); [node.dept_spec.spec, node.atom] end

          it_behaves_like :dimer_formation_in_different_envs do
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
                    [t1, t2] => [[[d1, d2], param_100_cross]],
                    [d1, d2] => [[[t1, t2], param_100_cross]],
                    [t1] => [[[b], param_100_front]],
                    [b] => [[[t1], param_100_front]]
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
                    [t1, t2] => [[[d1, d2], param_100_cross]],
                    [d1, d2] => [[[t1, t2], param_100_cross]],
                    [t1] => [[[b], param_100_front]],
                    [b] => [[[t1], param_100_front]]
                  }
                end

                it_behaves_like :check_grouped_nodes_graph do
                  let(:lateral_reactions) do
                    [dept_ewb_lateral_df, dept_mwb_lateral_df]
                  end
                end
              end
            end
          end

          it_behaves_like :many_similar_activated_bridges do
            let(:flatten_face_grouped_atoms) do
              [[t1], [fb], [cb]]
            end

            let(:nodes_list) do
              [
                [UniqueSpecie, t1],
                [UniqueSpecie, fb],
                [UniqueSpecie, cb]
              ]
            end

            let(:grouped_graph) do
              {
                [t1] => [[[fb], param_100_front], [[cb], param_100_cross]],
                [fb] => [[[t1], param_100_front]],
                [cb] => [[[t1], param_100_cross]]
              }
            end

            it_behaves_like :check_grouped_nodes_graph do
              let(:lateral_reactions) { [dept_small_ab_lateral_sdf] }
            end

            it_behaves_like :check_grouped_nodes_graph do
              let(:lateral_reactions) { [dept_big_ab_lateral_sdf] }
            end

            it_behaves_like :check_grouped_nodes_graph do
              let(:lateral_reactions) do
                [dept_small_ab_lateral_sdf, dept_big_ab_lateral_sdf]
              end
            end
          end

          it_behaves_like :methyl_incorporation_near_edge do
            it_behaves_like :check_grouped_nodes_graph do
              let(:flatten_face_grouped_atoms) do
                [[tm], [td], [dm, dd]]
              end

              let(:nodes_list) do
                [
                  [UniqueSpecie, tm],
                  [UniqueSpecie, td],
                  [UniqueSpecie, dm],
                  [UniqueSpecie, dd]
                ]
              end

              let(:grouped_graph) do
                {
                  [tm] => [[[dm], param_100_cross]],
                  [dm] => [[[tm], param_100_cross]],
                  [td] => [[[dd], param_110_front]],
                  [dd] => [[[td], param_110_cross]]
                }
              end
            end
          end
        end

      end
    end
  end
end
