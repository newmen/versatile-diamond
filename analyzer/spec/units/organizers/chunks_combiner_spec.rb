require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe ChunksCombiner, type: :organizer do
      subject { described_class.new(dept_dimer_formation) }

      describe '#combine' do
        let(:ind_chunk) { (ewb_chunk - end_chunk).independent_chunk }
        let(:chunks) { [end_chunk, ewb_chunk, middle_chunk, ind_chunk] }
        before do
          Tools::Config.surface_temperature(0, 'C')
          dimer_formation.rate = 1
          end_lateral_df.rate = 2
          ewb_lateral_df.rate = 33
          middle_lateral_df.rate = 4

          [
            dept_end_lateral_df,
            dept_ewb_lateral_df,
            dept_middle_lateral_df
          ].each do |dept_reaction|
            dept_reaction.send(:store_parent, dept_dimer_formation)
          end

          2.times { middle_chunk.store_parent(end_chunk) }
          ewb_chunk.store_parent(end_chunk)
          ewb_chunk.store_parent(ind_chunk)
        end

        let(:reactions) { subject.combine(chunks) }
        it 'check all combined reactions properties' do
          expect(reactions.size).to eq(2)

          expect(reactions.map(&:class).uniq).to eq([CombinedLateralReaction])
          expect(reactions.map(&:full_rate)).to match_array([4.0, 1.0])
          expect(reactions.map { |r| r.chunk.parents.size }).to match_array([3, 0])
        end
      end
    end

  end
end
