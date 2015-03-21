require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe ChunkResidual, type: :organizer do
      let(:big) { middle_chunk - end_chunk }
      let(:small) { big - end_chunk }
      let(:other) do
        concept = dimer_formation.lateral_duplicate('copy', [on_middle])
        middle_chunk - DependentLateralReaction.new(concept).chunk
      end

      describe '#<=>' do
        it { expect(small <=> big).to eq(-1) }
        it { expect(big <=> small).to eq(1) }

        it { expect(other <=> small).to eq(-1) }
        it { expect(small <=> other).to eq(1) }
      end

      describe '#<' do
        it { expect(small < big).to be_truthy }
        it { expect(big < small).to be_falsey }
      end

      describe '#<=' do
        it { expect(small <= big).to be_truthy }
        it { expect(big <= small).to be_falsey }
      end

      describe '#-' do
        it { expect(small).to be_a(described_class) }

        let(:ab) { middle_lateral_df.source.first }
        let(:aib) { middle_lateral_df.source.last }
        let(:rest_links) do
          {
            [ab, ab.atom(:ct)] => [
              [[aib, aib.atom(:ct)], position_100_front],
              [[dimer, dimer.atom(:cl)], position_100_cross],
              [[dimer_dup, dimer_dup.atom(:cl)], position_100_cross],
            ],
            [aib, aib.atom(:ct)] => [
              [[ab, ab.atom(:ct)], position_100_front],
              [[dimer, dimer.atom(:cr)], position_100_cross],
              [[dimer_dup, dimer_dup.atom(:cr)], position_100_cross],
            ],
          }
        end

        it { expect(small.links).to match_graph(rest_links) }
      end

      describe '#parents' do
        it { expect(big.parents).to eq([end_chunk]) }
        it { expect(small.parents).to eq([end_chunk] * 2) }
      end

      describe '#same?' do
        it { expect(small.same?(big)).to be_falsey }
        it { expect(big.same?(small)).to be_falsey }

        it { expect(other.same?(small)).to be_falsey }
        it { expect(small.same?(other)).to be_falsey }

        describe 'when same is presented' do
          let(:same) { big - end_chunk }

          it { expect(small == same).to be_falsey }
          it { expect(same == small).to be_falsey }

          it { expect(small.same?(same)).to be_truthy }
          it { expect(same.same?(small)).to be_truthy }
        end
      end
    end

  end
end
