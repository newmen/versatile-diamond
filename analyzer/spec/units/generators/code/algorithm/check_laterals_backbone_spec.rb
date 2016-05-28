require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe CheckLateralsBackbone, type: :algorithm, use: :chunks do
          let(:backbone) { described_class.new(generator, lateral_chunks, specie) }
          let(:specie) { generator.specie_class(spec.name) }

          describe '#final_graph' do
            it_behaves_like :dimer_formation_in_different_envs do
              describe 'dimer sidepiece' do
                let(:spec) { lateral_dimer }

                it_behaves_like :check_finite_graph do
                  let(:lateral_reactions) { [dept_end_lateral_df] }
                  let(:final_graph) do
                    {
                      [d1, d2] => [[[t2, t1], param_100_cross]]
                    }
                  end
                end

                it_behaves_like :check_finite_graph do
                  let(:lateral_reactions) { [dept_ewb_lateral_df] }
                  let(:final_graph) do
                    {
                      [d1, d2] => [[[t2, t1], param_100_cross]]
                    }
                  end
                end
              end

              describe 'bridge sidepiece' do
                it_behaves_like :check_finite_graph do
                  let(:lateral_reactions) { [dept_ewb_lateral_df] }
                  let(:spec) { lateral_bridge }
                  let(:final_graph) do
                    {
                      [b] => [[[t2], param_100_front]]
                    }
                  end
                end
              end
            end

            it_behaves_like :many_similar_activated_bridges do
              let(:spec) { front_bridge }
              let(:final_graph) do
                {
                  [cb] => [[[t2], param_100_cross]],
                  [fb] => [[[t2], param_100_front]]
                }
              end

              it_behaves_like :check_finite_graph do
                let(:lateral_reactions) { [dept_small_ab_lateral_sdf] }
              end

              it_behaves_like :check_finite_graph do
                let(:lateral_reactions) { [dept_big_ab_lateral_sdf] }
              end
            end

            it_behaves_like :methyl_incorporation_near_edge do
              it_behaves_like :check_finite_graph do
                let(:spec) { edge_dimer }
                let(:final_graph) do
                  {
                    [dm] => [[[tm], param_100_cross]],
                    [dd] => [[[td], param_110_cross]],
                    [td] => [[[ds], param_100_front]],
                    [tm] => [[[ms], param_amorph]]
                  }
                end
              end
            end
          end

          describe '#entry_nodes' do
            it_behaves_like :dimer_formation_in_different_envs do
              describe 'dimer sidepiece' do
                let(:spec) { lateral_dimer }
                let(:points_list) { [[d1, d2]] }

                it_behaves_like :check_entry_nodes do
                  let(:lateral_reactions) { [dept_end_lateral_df] }
                end

                it_behaves_like :check_entry_nodes do
                  let(:lateral_reactions) { [dept_ewb_lateral_df] }
                end
              end

              describe 'bridge sidepiece' do
                it_behaves_like :check_entry_nodes do
                  let(:lateral_reactions) { [dept_ewb_lateral_df] }
                  let(:spec) { lateral_bridge }
                  let(:points_list) { [[b]] }
                end
              end
            end

            it_behaves_like :many_similar_activated_bridges do
              let(:spec) { front_bridge }
              let(:points_list) { [[cb], [cb]] }

              it_behaves_like :check_entry_nodes do
                let(:lateral_reactions) { [dept_small_ab_lateral_sdf] }

                it 'same entry nodes are different' do
                  fst, snd = backbone.entry_nodes
                  expect(fst).not_to eq(snd)
                  expect(fst.map(&:original)).to eq(snd.map(&:original))
                end
              end

              it_behaves_like :check_entry_nodes do
                let(:lateral_reactions) { [dept_big_ab_lateral_sdf] }
              end
            end

            it_behaves_like :methyl_incorporation_near_edge do
              it_behaves_like :check_entry_nodes do
                let(:spec) { edge_dimer }
                let(:points_list) { [[dd, dm]] }
              end
            end
          end

          describe '#action_nodes' do
            it_behaves_like :dimer_formation_in_different_envs do
              describe 'dimer sidepiece' do
                let(:spec) { lateral_dimer }
                let(:atoms_lists) { [d1, d2] }

                it_behaves_like :check_action_nodes do
                  let(:lateral_reactions) { [dept_end_lateral_df] }
                end

                it_behaves_like :check_action_nodes do
                  let(:lateral_reactions) { [dept_ewb_lateral_df] }
                end
              end

              describe 'bridge sidepiece' do
                it_behaves_like :check_action_nodes do
                  let(:lateral_reactions) { [dept_ewb_lateral_df] }
                  let(:spec) { lateral_bridge }
                  let(:atoms_lists) { [b] }
                end
              end
            end

            it_behaves_like :many_similar_activated_bridges do
              let(:spec) { front_bridge }
              let(:atoms_lists) { [fb] }

              it_behaves_like :check_action_nodes do
                let(:lateral_reactions) { [dept_small_ab_lateral_sdf] }
              end

              it_behaves_like :check_action_nodes do
                let(:lateral_reactions) { [dept_big_ab_lateral_sdf] }
              end
            end

            it_behaves_like :methyl_incorporation_near_edge do
              it_behaves_like :check_action_nodes do
                let(:spec) { edge_dimer }
                let(:atoms_lists) { [dd, dm] }
              end
            end
          end

          describe '#ordered_graph_from' do
            it_behaves_like :dimer_formation_in_different_envs do
              describe 'dimer sidepiece' do
                let(:spec) { lateral_dimer }

                describe 'just cross' do
                  let(:ordered_graph) do
                    [
                      [[d1, d2], [[[t2, t1], param_100_cross]]]
                    ]
                  end

                  it_behaves_like :check_ordered_graph do
                    let(:lateral_reactions) { [dept_end_lateral_df] }
                  end

                  it_behaves_like :check_ordered_graph do
                    let(:lateral_reactions) { [dept_middle_lateral_df] }
                  end
                end

                describe 'many sides' do
                  it_behaves_like :check_ordered_graph do
                    let(:ordered_graph) do
                      [
                        [[d1, d2], [[[t2, t1], param_100_cross]]]
                      ]
                    end

                    let(:lateral_reactions) { [dept_ewb_lateral_df] }
                  end
                end
              end

              describe 'bridge sidepiece' do
                let(:spec) { lateral_bridge }
                let(:ordered_graph) do
                  [
                    [[b], [[[t2], param_100_front]]]
                  ]
                end

                it_behaves_like :check_ordered_graph do
                  let(:lateral_reactions) { [dept_ewb_lateral_df] }
                end

                it_behaves_like :check_ordered_graph do
                  let(:lateral_reactions) { [dept_mwb_lateral_df] }
                end
              end
            end

            it_behaves_like :many_similar_activated_bridges do
              shared_examples_for :check_ordered_graph_from do
                it_behaves_like :check_ordered_graph do
                  let(:lateral_reactions) { [dept_small_ab_lateral_sdf] }
                end

                it_behaves_like :check_ordered_graph do
                  let(:lateral_reactions) { [dept_big_ab_lateral_sdf] }
                end
              end

              it_behaves_like :check_ordered_graph_from do
                let(:spec) { front_bridge }
                let(:entry_node) { backbone.entry_nodes.first }
                let(:ordered_graph) do
                  [
                    [[cb], [[[t2], param_100_front]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph_from do
                let(:spec) { front_bridge }
                let(:entry_node) { backbone.entry_nodes.last }
                let(:ordered_graph) do
                  [
                    [[cb], [[[t2], param_100_cross]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph_from do
                let(:spec) { cross_bridge }
                let(:entry_node) { backbone.entry_nodes.first }
                let(:ordered_graph) do
                  [
                    [[cb], [[[t2], param_100_front]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph_from do
                let(:spec) { cross_bridge }
                let(:entry_node) { backbone.entry_nodes.last }
                let(:ordered_graph) do
                  [
                    [[cb], [[[t2], param_100_cross]]]
                  ]
                end
              end
            end

            it_behaves_like :methyl_incorporation_near_edge do
              it_behaves_like :check_ordered_graph do
                let(:spec) { edge_dimer }
                let(:ordered_graph) do
                  [
                    [[dd], [[[td], param_110_cross]]],
                    [[dm], [[[tm], param_100_cross]]]
                  ]
                end
              end
            end
          end
        end

      end
    end
  end
end
