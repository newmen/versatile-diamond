require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe ChunksCombiner, type: :organizer do
      subject { described_class.new(dept_dimer_formation) }

      describe '#combine' do
        shared_examples_for :check_combined_reactions do
          let(:reactions) { subject.combine(chunks) }
          it 'combined reactions should be' do
            expect(reactions.map(&:class).uniq).to eq([CombinedLateralReaction])
            expect(reactions.map(&:full_rate)).to match_array(rates)
            expect(reactions.map { |r| r.chunk.parents.size }).to eq(parents)
          end
        end

        describe 'one self incompatible chunk' do
          let(:chunks) { [ewb_chunk] }
          before do
            Tools::Config.surface_temperature(0, 'C')
            dimer_formation.activation = 0
            dimer_formation.rate = 1
            ewb_lateral_df.activation = 0
            ewb_lateral_df.rate = 2

            dept_ewb_lateral_df.send(:store_parent, dept_dimer_formation)
          end

          it_behaves_like :check_combined_reactions do
            let(:rates) { [1.0, 1.0, 1.0, 2.0] }
            let(:parents) { [0, 0, 1, 2] }
          end
        end

        describe 'many chunks' do
          let(:ind_chunk) { (ewb_chunk - end_chunk).independent_chunk }
          let(:chunks) { [end_chunk, ewb_chunk, middle_chunk, ind_chunk] }
          before do
            Tools::Config.surface_temperature(0, 'C')
            dimer_formation.activation = 0
            dimer_formation.rate = 1
            end_lateral_df.activation = 0
            end_lateral_df.rate = 2
            ewb_lateral_df.activation = 0
            ewb_lateral_df.rate = 33
            middle_lateral_df.activation = 0
            middle_lateral_df.rate = 4

            [
              dept_end_lateral_df,
              dept_ewb_lateral_df,
              dept_middle_lateral_df
            ].each do |dept_reaction|
              dept_reaction.send(:store_parent, dept_dimer_formation)
            end
          end

          it_behaves_like :check_combined_reactions do
            let(:rates) { [1.0, 4.0] }
            let(:parents) { [0, 2] }
          end
        end
      end
    end

  end
end
