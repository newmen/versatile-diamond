require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe MergedChunk, type: :organizer do
      before { dept_end_lateral_df.send(:store_parent, typical_reaction) }
      let(:typical_reaction) { dept_dimer_formation }
      let(:mrg_chunk) do
        described_class.new(typical_reaction, [end_chunk] * 2, {})
      end

      let(:ab) { dimer_formation.source.first }
      let(:aib) { dimer_formation.source.last }

      describe '#targets' do
        let(:targets) { Set[[ab, ab.atom(:ct)], [aib, aib.atom(:ct)]] }
        it { expect(mrg_chunk.targets).to eq(targets) }
      end

      describe '#links' do
        let(:veiled_dimer) do
          (mrg_chunk.links.keys.map(&:first) - [ab, aib, dimer]).first
        end
        let(:links) do
          {
            [ab, ab.atom(:ct)] => [
              [[dimer, dimer.atom(:cl)], position_100_cross],
              [[veiled_dimer, veiled_dimer.atom(:cl)], position_100_cross],
            ],
            [aib, aib.atom(:ct)] => [
              [[dimer, dimer.atom(:cr)], position_100_cross],
              [[veiled_dimer, veiled_dimer.atom(:cr)], position_100_cross],
            ],
            [dimer, dimer.atom(:cr)] => [
              [[aib, aib.atom(:ct)], position_100_cross],
              [[dimer, dimer.atom(:cl)], bond_100_front],
              [[dimer, dimer.atom(:crb)], bond_110_cross],
              [[dimer, dimer.atom(:_cr0)], bond_110_cross]
            ],
            [dimer, dimer.atom(:crb)] => [
              [[dimer, dimer.atom(:cr)], bond_110_front],
              [[dimer, dimer.atom(:_cr0)], position_100_front]
            ],
            [dimer, dimer.atom(:_cr0)] => [
              [[dimer, dimer.atom(:cr)], bond_110_front],
              [[dimer, dimer.atom(:crb)], position_100_front]
            ],
            [dimer, dimer.atom(:cl)] => [
              [[ab, ab.atom(:ct)], position_100_cross],
              [[dimer, dimer.atom(:cr)], bond_100_front],
              [[dimer, dimer.atom(:clb)], bond_110_cross],
              [[dimer, dimer.atom(:_cr1)], bond_110_cross]
            ],
            [dimer, dimer.atom(:clb)] => [
              [[dimer, dimer.atom(:cl)], bond_110_front],
              [[dimer, dimer.atom(:_cr1)], position_100_front]
            ],
            [dimer, dimer.atom(:_cr1)] => [
              [[dimer, dimer.atom(:cl)], bond_110_front],
              [[dimer, dimer.atom(:clb)], position_100_front],
            ],
            [veiled_dimer, veiled_dimer.atom(:cr)] => [
              [[aib, aib.atom(:ct)], position_100_cross],
              [[veiled_dimer, veiled_dimer.atom(:cl)], bond_100_front],
              [[veiled_dimer, veiled_dimer.atom(:crb)], bond_110_cross],
              [[veiled_dimer, veiled_dimer.atom(:_cr0)], bond_110_cross]
            ],
            [veiled_dimer, veiled_dimer.atom(:crb)] => [
              [[veiled_dimer, veiled_dimer.atom(:cr)], bond_110_front],
              [[veiled_dimer, veiled_dimer.atom(:_cr0)], position_100_front]
            ],
            [veiled_dimer, veiled_dimer.atom(:_cr0)] => [
              [[veiled_dimer, veiled_dimer.atom(:cr)], bond_110_front],
              [[veiled_dimer, veiled_dimer.atom(:crb)], position_100_front]
            ],
            [veiled_dimer, veiled_dimer.atom(:cl)] => [
              [[ab, ab.atom(:ct)], position_100_cross],
              [[veiled_dimer, veiled_dimer.atom(:cr)], bond_100_front],
              [[veiled_dimer, veiled_dimer.atom(:clb)], bond_110_cross],
              [[veiled_dimer, veiled_dimer.atom(:_cr1)], bond_110_cross]
            ],
            [veiled_dimer, veiled_dimer.atom(:clb)] => [
              [[veiled_dimer, veiled_dimer.atom(:cl)], bond_110_front],
              [[veiled_dimer, veiled_dimer.atom(:_cr1)], position_100_front]
            ],
            [veiled_dimer, veiled_dimer.atom(:_cr1)] => [
              [[veiled_dimer, veiled_dimer.atom(:cl)], bond_110_front],
              [[veiled_dimer, veiled_dimer.atom(:clb)], position_100_front],
            ],
          }
        end

        it { expect(mrg_chunk.links).to match_graph(links) }
      end

      describe '#<=>' do
        before { dept_ewb_lateral_df.send(:store_parent, typical_reaction) }
        let(:other) do
          chunks = [(ewb_chunk - end_chunk).independent_chunk] + [end_chunk] * 2
          described_class.new(typical_reaction, chunks, {})
        end

        it { expect(mrg_chunk <=> other).to eq(-1) }
        it { expect(other <=> mrg_chunk).to eq(1) }
      end

      describe '#original?' do
        it { expect(mrg_chunk.original?).to be_falsey }
      end

      describe '#lateral_reaction' do
        it { expect(mrg_chunk.lateral_reaction).to be_a(CombinedLateralReaction) }
        it { expect(mrg_chunk.lateral_reaction).to eq(mrg_chunk.lateral_reaction) }
      end

      describe '#tail_name' do
        let(:tail_name) { (['dimer'] * 2).join(' and ') }
        it { expect(mrg_chunk.tail_name).to eq(tail_name) }
      end
    end

  end
end
