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
      let(:bwr) { mwb_chunk - end_chunk - end_chunk }
      let(:swr) { mwb_chunk - middle_chunk }

      describe '#<=>' do
        it { expect(small <=> big).to eq(-1) }
        it { expect(big <=> small).to eq(1) }

        it { expect(small <=> other).to eq(-1) }
        it { expect(other <=> small).to eq(1) }

        it { expect(bwr <=> swr).to eq(-1) }
        it { expect(swr <=> bwr).to eq(1) }
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
              [[dimer, dimer.atom(:cl)], position_100_cross],
              [[dimer_dup, dimer_dup.atom(:cl)], position_100_cross],
            ],
            [aib, aib.atom(:ct)] => [
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

      describe '#independent_chunk' do
        before { dept_mwb_lateral_df.send(:store_parent, dept_dimer_formation) }
        let(:independent_chunk) { bwr.independent_chunk }
        it { expect(independent_chunk).to be_a(IndependentChunk) }

        let(:aib) { mwb_lateral_df.source.last }
        let(:links) do
          {
            [aib, aib.atom(:ct)] => [
              [[bridge, bridge.atom(:ct)], position_100_front],
            ],
            [bridge, bridge.atom(:ct)] => [
              [[aib, aib.atom(:ct)], position_100_front],
              [[bridge, bridge.atom(:cr)], bond_110_cross],
              [[bridge, bridge.atom(:cl)], bond_110_cross],
            ],
            [bridge, bridge.atom(:cr)] => [
              [[bridge, bridge.atom(:ct)], bond_110_front],
              [[bridge, bridge.atom(:cl)], position_100_front],
            ],
            [bridge, bridge.atom(:cl)] => [
              [[bridge, bridge.atom(:ct)], bond_110_front],
              [[bridge, bridge.atom(:cr)], position_100_front],
            ]
          }
        end
        it { expect(independent_chunk.links).to match_graph(links) }
      end

      describe '#fully_matched?' do
        it { expect(big.fully_matched?).to be_falsey }
        it { expect(small.fully_matched?).to be_truthy }
        it { expect(other.fully_matched?).to be_truthy }
        it { expect(bwr.fully_matched?).to be_falsey }
        it { expect(swr.fully_matched?).to be_falsey }
      end

      describe '#same?' do
        it { expect(small.same?(big)).to be_falsey }
        it { expect(big.same?(small)).to be_falsey }

        it { expect(other.same?(small)).to be_falsey }
        it { expect(small.same?(other)).to be_falsey }

        it { expect(bwr.same?(swr)).to be_falsey }
        it { expect(swr.same?(bwr)).to be_falsey }

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
