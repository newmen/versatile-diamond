require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe CheckLateralsBackbone, type: :algorithm do
          let(:generator) do
            stub_generator(
              typical_reactions: [typical_reaction],
              lateral_reactions: lateral_reactions
            )
          end
          let(:reaction) { generator.reaction_class(typical_reaction.name) }
          let(:specie) { generator.specie_class(spec.name) }
          let(:backbone) { described_class.new(generator, subject, specie) }
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
            describe 'dimer sidepiece' do
              let(:spec) { lateral_dimer }
              let(:final_graph) do
                {
                  [d1, d2] => [[[t2, t1], param_100_cross]]
                }
              end

              it_behaves_like :check_finite_graph do
                let(:lateral_reactions) { [dept_end_lateral_df] }
              end

              it_behaves_like :check_finite_graph do
                let(:lateral_reactions) { [dept_ewb_lateral_df] }
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

          describe '#entry_nodes' do
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

          describe '#ordered_graph_from' do
            describe 'dimer sidepiece' do
              let(:spec) { lateral_dimer }
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

              it_behaves_like :check_ordered_graph do
                let(:lateral_reactions) { [dept_ewb_lateral_df] }
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
        end

      end
    end
  end
end
