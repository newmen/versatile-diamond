require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe LookAroundBackbone, type: :algorithm, use: :chunks do
          let(:backbone) { described_class.new(generator, lateral_chunks) }

          describe '#final_graph' do
            it_behaves_like :dimer_formation_in_different_envs do
              it_behaves_like :check_finite_graph do
                let(:lateral_reactions) { [dept_end_lateral_df] }
                let(:final_graph) do
                  {
                    [t1, t2] => [[[:cl, :cr], param_100_cross]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:lateral_reactions) { [dept_ewb_lateral_df] }
                let(:final_graph) do
                  {
                    [t1] => [[[b], param_100_front]],
                    [t1, t2] => [[[:cl, :cr], param_100_cross]]
                  }
                end
              end
            end

            it_behaves_like :many_similar_activated_bridges do
              let(:final_graph) do
                {
                  [t] => [[[cb1], param_100_cross], [[fb2], param_100_front]]
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
                let(:final_graph) do
                  {
                    [:cb] => [[[sdl], param_100_cross]],
                    [tdl] => [[[:cr], param_110_front]]
                  }
                end
              end
            end
          end

          describe '#entry_nodes' do
            it_behaves_like :dimer_formation_in_different_envs do
              it_behaves_like :check_entry_nodes do
                let(:lateral_reactions) { [dept_end_lateral_df] }
                let(:points_list) { [[:ct, :ct]] }
              end

              it_behaves_like :check_entry_nodes do
                let(:lateral_reactions) { [dept_ewb_lateral_df] }
                let(:points_list) { [[:ct, :ct], [:ct]] }
              end
            end

            it_behaves_like :many_similar_activated_bridges do
              let(:points_list) { [[:ct], [:ct]] }

              it_behaves_like :check_entry_nodes do
                let(:lateral_reactions) { [dept_small_ab_lateral_sdf] }

                it 'same entry nodes are different' do
                  fst, snd = backbone.entry_nodes
                  expect(fst).to eq(snd)
                  expect(fst).not_to equal(snd)
                end
              end

              it_behaves_like :check_entry_nodes do
                let(:lateral_reactions) { [dept_big_ab_lateral_sdf] }
              end
            end

            it_behaves_like :methyl_incorporation_near_edge do
              it_behaves_like :check_entry_nodes do
                let(:points_list) { [[:cl, :cb]] }
              end
            end
          end

          describe '#action_nodes' do
            it_behaves_like :dimer_formation_in_different_envs do
              let(:atoms_lists) { [:ct, :ct] }

              it_behaves_like :check_action_nodes do
                let(:lateral_reactions) { [dept_end_lateral_df] }
              end

              it_behaves_like :check_action_nodes do
                let(:lateral_reactions) { [dept_ewb_lateral_df] }
              end
            end

            it_behaves_like :many_similar_activated_bridges do
              let(:atoms_lists) { [:ct, :ct] }

              it_behaves_like :check_action_nodes do
                let(:lateral_reactions) { [dept_small_ab_lateral_sdf] }
              end

              it_behaves_like :check_action_nodes do
                let(:lateral_reactions) { [dept_big_ab_lateral_sdf] }
              end
            end

            it_behaves_like :methyl_incorporation_near_edge do
              it_behaves_like :check_action_nodes do
                let(:atoms_lists) { [:cl, :cb] }
              end
            end
          end

          describe '#ordered_graph_from' do
            it_behaves_like :dimer_formation_in_different_envs do
              describe 'just cross sidepieces' do
                let(:ordered_graph) do
                  [
                    [[t1, t2], [[[:cl, :cr], param_100_cross]]]
                  ]
                end

                it_behaves_like :check_ordered_graph do
                  let(:lateral_reactions) { [dept_end_lateral_df] }
                end

                it_behaves_like :check_ordered_graph do
                  let(:lateral_reactions) { [dept_middle_lateral_df] }
                end

                it_behaves_like :check_ordered_graph do
                  let(:lateral_reactions) do
                    [dept_end_lateral_df, dept_middle_lateral_df]
                  end
                end
              end

              describe 'diff-side neighbours' do
                shared_examples_for :check_all_ordered_graphs do
                  it_behaves_like :check_ordered_graph do
                    let(:lateral_reactions) { [dept_ewb_lateral_df] }
                  end

                  it_behaves_like :check_ordered_graph do
                    let(:lateral_reactions) { [dept_mwb_lateral_df] }
                  end

                  it_behaves_like :check_ordered_graph do
                    let(:lateral_reactions) do
                      [dept_ewb_lateral_df, dept_mwb_lateral_df]
                    end
                  end
                end

                it_behaves_like :check_all_ordered_graphs do
                  let(:entry_node) { backbone.entry_nodes.first }
                  let(:ordered_graph) do
                    [
                      [[t1, t2], [[[:cl, :cr], param_100_cross]]]
                    ]
                  end
                end

                it_behaves_like :check_all_ordered_graphs do
                  let(:entry_node) { backbone.entry_nodes.last }
                  let(:ordered_graph) do
                    [
                      [[t1], [[[b], param_100_front]]]
                    ]
                  end
                end
              end
            end

            it_behaves_like :many_similar_activated_bridges do
              shared_examples_for :check_all_ordered_graphs do
                it_behaves_like :check_ordered_graph do
                  let(:lateral_reactions) { [dept_small_ab_lateral_sdf] }
                end

                it_behaves_like :check_ordered_graph do
                  let(:lateral_reactions) { [dept_big_ab_lateral_sdf] }
                end
              end

              it_behaves_like :check_all_ordered_graphs do
                let(:entry_node) { backbone.entry_nodes.first }
                let(:ordered_graph) do
                  [
                    [[t], [[[fb1], param_100_front]]]
                  ]
                end
              end

              it_behaves_like :check_all_ordered_graphs do
                let(:entry_node) { backbone.entry_nodes.last }
                let(:ordered_graph) do
                  [
                    [[t], [[[cb1], param_100_cross]]]
                  ]
                end
              end
            end

            it_behaves_like :methyl_incorporation_near_edge do
              it_behaves_like :check_ordered_graph do
                let(:ordered_graph) do
                  [
                    [[tdl], [[[:cr], param_110_front]]],
                    [[:cb], [[[sdl], param_100_cross]]]
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
