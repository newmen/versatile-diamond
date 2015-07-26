require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe ChunksCombiner, type: :organizer do
      describe '#combine' do
        before do
          Tools::Config.surface_temperature(0, 'C')
          parent_reaction = typical_reaction.reaction
          parent_reaction.activation = 0
          parent_reaction.rate = 1

          lateral_reactions.each { |lr| lr.reaction.activation = 0 }
          setup_rates
          stub_results({
            typical_reactions: [typical_reaction],
            lateral_reactions: lateral_reactions
          })
        end


        shared_examples_for :check_combined_reactions do
          let(:cmb_reactions) { typical_reaction.children - lateral_reactions }
          it 'combined reactions should be' do
            expect(cmb_reactions.map(&:class).uniq).to eq([CombinedLateralReaction])
            expect(cmb_reactions.map(&:full_rate)).to match_array(rates)
            expect(cmb_reactions.map { |r| r.chunk.parents.size }).to eq(parents)
            expect(cmb_reactions.map { |r| r.chunk.internal_chunks.size }).
              to eq(internal_chunks)
          end
        end

        describe 'one self incompatible chunk' do
          let(:typical_reaction) { dept_dimer_formation }
          let(:lateral_reactions) { [dept_ewb_lateral_df] }
          let(:setup_rates) do
            ewb_lateral_df.rate = 2
          end

          it_behaves_like :check_combined_reactions do
            let(:rates) { [1.0, 1.0, 1.0, 2.0] }
            let(:parents) { [0, 0, 2, 2] }
            let(:internal_chunks) { [1, 1, 3, 2] }
          end
        end

        describe 'many chunks' do
          let(:typical_reaction) { dept_dimer_formation }
          let(:lateral_reactions) do
            [dept_end_lateral_df, dept_ewb_lateral_df, dept_middle_lateral_df]
          end
          let(:setup_rates) do
            end_lateral_df.rate = 2
            ewb_lateral_df.rate = 33
            middle_lateral_df.rate = 4
          end

          it_behaves_like :check_combined_reactions do
            let(:rates) { [1.0, 4.0] }
            let(:parents) { [0, 2] }
            let(:internal_chunks) { [1, 3] }
          end
        end

        describe 'many similar chunks (small case)' do
          let(:typical_reaction) { dept_symmetric_dimer_formation }
          let(:lateral_reactions) { [dept_small_ab_lateral_sdf] }
          let(:setup_rates) do
            small_ab_lateral_sdf.rate = 10
          end

          it_behaves_like :check_combined_reactions do
            let(:rates) { [5.0, 10.0] }
            let(:parents) { [0, 2] }
            let(:internal_chunks) { [1, 3] }
          end
        end
      end
    end

  end
end
