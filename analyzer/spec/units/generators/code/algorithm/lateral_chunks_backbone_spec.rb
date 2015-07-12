require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe LateralChunksBackbone, type: :algorithm do
          let(:generator) do
            stub_generator(
              typical_reactions: [typical_reaction],
              lateral_reactions: lateral_reactions
            )
          end
          let(:reaction) { generator.reaction_class(typical_reaction.name) }
          let(:chunks) { lateral_reactions.map(&:chunk) }
          let(:backbone) { described_class.new(generator, subject) }
          let(:sidepiece_specs) { subject.sidepiece_specs.to_a }
          subject { reaction.lateral_chunks }

          let(:typical_reaction) { dept_dimer_formation }
          let(:t1) { df_source.first.atom(:ct) }
          let(:t2) { df_source.last.atom(:ct) }

          let(:lateral_dimer) do
            sidepiece_specs.select { |spec| spec.name == :dimer }.first
          end
          let(:d1) { lateral_dimer.atom(:cr) }
          let(:d2) { lateral_dimer.atom(:cl) }

          let(:lateral_bridge) { (sidepiece_specs - [lateral_dimer]).first }
          let(:b) { lateral_bridge.atom(:ct) }

          describe '#final_graph' do
            it_behaves_like :check_finite_graph do
              let(:lateral_reactions) { [dept_end_lateral_df] }
              let(:final_graph) do
                {
                  [t1, t2] => [[[d2, d1], param_100_cross]]
                }
              end
            end

            it_behaves_like :check_finite_graph do
              let(:lateral_reactions) { [dept_ewb_lateral_df] }
              let(:final_graph) do
                {
                  [t2] => [[[b], param_100_front]],
                  [t2, t1] => [[[d1, d2], param_100_cross]]
                }
              end
            end
          end

          describe '#entry_nodes' do
            it_behaves_like :check_entry_nodes do
              let(:lateral_reactions) { [dept_end_lateral_df] }
              let(:points_list) { [[t1, t2]] }
            end

            it_behaves_like :check_entry_nodes do
              let(:lateral_reactions) { [dept_ewb_lateral_df] }
              let(:points_list) { [[t2], [t2, t1]] }
            end
          end

          describe '#ordered_graph_from' do
            describe 'just cross sidepieces' do
              let(:ordered_graph) do
                [
                  [[t1, t2], [[[d2, d1], param_100_cross]]]
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
                    [[t2], [[[b], param_100_front]]]
                  ]
                end
              end

              it_behaves_like :check_all_ordered_graphs do
                let(:entry_node) { backbone.entry_nodes.last }
                let(:ordered_graph) do
                  [
                    [[t2, t1], [[[d1, d2], param_100_cross]]]
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
