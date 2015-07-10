require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ChunksBackbone, type: :algorithm do
          let(:generator) do
            stub_generator(
              typical_reactions: [dependent_typical_reaction],
              lateral_reactions: dependent_lateral_reactions
            )
          end
          let(:reaction) { generator.reaction_class(dependent_typical_reaction.name) }
          let(:chunks) { dependent_lateral_reactions.map(&:chunk) }
          let(:backbone) { described_class.new(generator, subject) }
          let(:sidepiece_specs) { subject.sidepiece_specs.to_a }
          subject { reaction.lateral_chunks }

          let(:dependent_typical_reaction) { dept_dimer_formation }
          let(:t1) { df_source.first.atom(:ct) }
          let(:t2) { df_source.last.atom(:ct) }

          let(:sidepiece_dimers) do
            sidepiece_specs.select { |spec| spec.name == :dimer }
          end
          let(:first_lateral_dimer) { sidepiece_dimers.first }
          let(:df1) { first_lateral_dimer.atom(:cr) }
          let(:df2) { first_lateral_dimer.atom(:cl) }

          let(:second_lateral_dimer) { sidepiece_dimers.last }
          let(:ds1) { second_lateral_dimer.atom(:cr) }
          let(:ds2) { second_lateral_dimer.atom(:cl) }

          let(:sidepiece_bridge) { (sidepiece_specs - sidepiece_dimers).first }
          let(:b) { sidepiece_bridge.atom(:ct) }

          describe '#final_graph' do
            it_behaves_like :check_finite_graph do
              let(:dependent_lateral_reactions) { [dept_end_lateral_df] }
              let(:final_graph) do
                {
                  [t1, t2] => [
                    [[df2, df1], param_100_cross], [[ds2, ds1], param_100_cross]
                  ]
                }
              end
            end

            it_behaves_like :check_finite_graph do
              let(:dependent_lateral_reactions) { [dept_ewb_lateral_df] }
              let(:final_graph) do
                {
                  [t2] => [[[b], param_100_front]],
                  [t2, t1] => [
                    [[df1, df2], param_100_cross], [[ds1, ds2], param_100_cross]
                  ]
                }
              end
            end
          end

          describe '#entry_nodes' do
            it_behaves_like :check_entry_nodes do
              let(:dependent_lateral_reactions) { [dept_end_lateral_df] }
              let(:points_list) { [[t1, t2]] }
            end

            it_behaves_like :check_entry_nodes do
              let(:dependent_lateral_reactions) { [dept_ewb_lateral_df] }
              let(:points_list) { [[t2, t1]] }
            end
          end

          describe '#ordered_graph_from' do
            describe 'just cross sidepieces and several chunks users' do
              let(:ordered_graph) do
                [
                  [[t1, t2], [
                    [[df2, df1], param_100_cross], [[ds2, ds1], param_100_cross]
                  ]]
                ]
              end

              it_behaves_like :check_ordered_graph do
                let(:dependent_lateral_reactions) { [dept_end_lateral_df] }
              end

              it_behaves_like :check_ordered_graph do
                let(:dependent_lateral_reactions) do
                  [dept_end_lateral_df, dept_middle_lateral_df]
                end
              end
            end

            describe 'just cross sidepieces and one chunk user' do
              it_behaves_like :check_ordered_graph do
                let(:dependent_lateral_reactions) { [dept_middle_lateral_df] }
                let(:ordered_graph) do
                  [
                    [[t2], [[[df1, ds1], param_100_cross]]],
                    [[t1], [[[df2, ds2], param_100_cross]]]
                  ]
                end
              end
            end

            describe 'diff-side neighbours and several chunks users' do
              let(:ordered_graph) do
                [
                  [[t2], [[[b], param_100_front]]],
                  [[t2, t1], [
                    [[df1, df2], param_100_cross], [[ds1, ds2], param_100_cross]
                  ]]
                ]
              end

              it_behaves_like :check_ordered_graph do
                let(:dependent_lateral_reactions) { [dept_ewb_lateral_df] }
              end

              it_behaves_like :check_ordered_graph do
                let(:dependent_lateral_reactions) do
                  [dept_ewb_lateral_df, dept_mwb_lateral_df]
                end
              end
            end

            describe 'diff-side neighbours and one chunk user' do
              it_behaves_like :check_ordered_graph do
                let(:dependent_lateral_reactions) { [dept_mwb_lateral_df] }
                let(:ordered_graph) do
                  [
                    [[t2], [[[b], param_100_front]]],
                    [[t1], [[[df2, ds2], param_100_cross]]],
                    [[t2], [[[df1, ds1], param_100_cross]]]
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
