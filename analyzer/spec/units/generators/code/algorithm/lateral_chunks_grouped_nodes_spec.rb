require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe LateralChunksGroupedNodes, type: :algorithm, use: :chunks do
          def node_to_vertex(node)
            [node.spec.spec, node.atom]
          end

          let(:grouped_nodes) { described_class.new(generator, lateral_chunks) }
          subject { lateral_chunks }

          let(:big_links_method) { :links }
          it_behaves_like :dimer_formation_in_different_envs do
            describe 'just cross neighbours' do
              let(:flatten_face_grouped_atoms) { [[:ct, :ct], [:cl, :cr]] }
              let(:nodes_list) do
                [
                  [Instances::UniqueReactant, :ct],
                  [Instances::UniqueReactant, :ct],
                  [Instances::UniqueReactant, :cl],
                  [Instances::UniqueReactant, :cr]
                ]
              end

              let(:grouped_graph) do
                {
                  [t1, t2] => [[[:cr, :cl], param_100_cross]],
                  [:cr, :cl] => [[[t1, t2], param_100_cross]]
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
              let(:flatten_face_grouped_atoms) do
                [[:ct, :ct], [:cl, :cr], [:ct]]
              end

              let(:nodes_list) do
                [
                  [Instances::UniqueReactant, :ct],
                  [Instances::UniqueReactant, :ct],
                  [Instances::UniqueReactant, :cl],
                  [Instances::UniqueReactant, :cr],
                  [Instances::UniqueReactant, :ct]
                ]
              end

              let(:grouped_graph) do
                {
                  [t1, t2] => [[[:cr, :cl], param_100_cross]],
                  [:cr, :cl] => [[[t1, t2], param_100_cross]],
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

              it_behaves_like :check_grouped_nodes_graph do
                let(:lateral_reactions) do
                  [dept_ewb_lateral_df, dept_mwb_lateral_df]
                end
              end
            end
          end

          it_behaves_like :many_similar_activated_bridges do
            let(:flatten_face_grouped_atoms) do
              [[:ct], [:ct], [:ct]]
            end

            let(:nodes_list) do
              [
                [Instances::UniqueReactant, :ct],
                [Instances::UniqueReactant, :ct],
                [Instances::UniqueReactant, :ct]
              ]
            end

            let(:grouped_graph) do
              {
                [t] => [[[cb1], param_100_cross], [[fb2], param_100_front]],
                [cb1] => [[[t], param_100_cross]],
                [fb2] => [[[t], param_100_front]]
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
                [[:cb], [:cl], [:cr, :cl]]
              end

              let(:nodes_list) do
                [
                  [Instances::UniqueReactant, :cb],
                  [Instances::UniqueReactant, :cl],
                  [Instances::UniqueReactant, :cr],
                  [Instances::UniqueReactant, :cl]
                ]
              end

              let(:grouped_graph) do
                {
                  [tdl] => [[[:cr], param_110_front]],
                  [:cr] => [[[tdl], param_110_cross]],
                  [:cb] => [[[sdl], param_100_cross]],
                  [sdl] => [[[:cb], param_100_cross]]
                }
              end
            end
          end
        end

      end
    end
  end
end
