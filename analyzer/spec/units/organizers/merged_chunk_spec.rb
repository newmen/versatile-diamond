require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe MergedChunk, type: :organizer do
      before do
        stub_results({
          typical_reactions: [typical_reaction],
          lateral_reactions: lateral_reactions
        })
      end

      let(:typical_reaction) { dept_dimer_formation }
      let(:lateral_reactions) { [dept_end_lateral_df] }
      let(:cmb_lateral_reactions) { typical_reaction.children - lateral_reactions }
      let(:mrg_chunk) { cmb_lateral_reactions.first.chunk }

      let(:ab) { dimer_formation.source.first }
      let(:aib) { dimer_formation.source.last }

      describe '#replace_target' do
        subject { mrg_chunk.replace_target(from, to) }
        let(:from) { mrg_chunk.targets.first }
        let(:to) { [extra_activated_bridge, extra_activated_bridge.atom(:ct)] }
        it { expect(subject).to be_a(CombinedChunk) }
        it { expect(subject).not_to eq(mrg_chunk) }
      end

      describe '#targets' do
        let(:targets) { Set[[ab, ab.atom(:ct)], [aib, aib.atom(:ct)]] }
        it { expect(mrg_chunk.targets).to eq(targets) }
      end

      describe '#links' do
        let(:veiled_dimer) do
          (mrg_chunk.links.keys.map(&:first) - [ab, aib, dimer_base]).first
        end
        let(:links) do
          {
            [ab, ab.atom(:ct)] => [
              [[dimer_base, dimer_base.atom(:cr)], position_100_cross],
              [[veiled_dimer, veiled_dimer.atom(:cr)], position_100_cross],
            ],
            [aib, aib.atom(:ct)] => [
              [[dimer_base, dimer_base.atom(:cl)], position_100_cross],
              [[veiled_dimer, veiled_dimer.atom(:cl)], position_100_cross],
            ],
            [dimer_base, dimer_base.atom(:cr)] => [
              [[ab, ab.atom(:ct)], position_100_cross],
              [[dimer_base, dimer_base.atom(:cl)], bond_100_front],
              [[dimer_base, dimer_base.atom(:crb)], bond_110_cross],
              [[dimer_base, dimer_base.atom(:_cr0)], bond_110_cross]
            ],
            [dimer_base, dimer_base.atom(:crb)] => [
              [[dimer_base, dimer_base.atom(:cr)], bond_110_front],
              [[dimer_base, dimer_base.atom(:_cr0)], position_100_front]
            ],
            [dimer_base, dimer_base.atom(:_cr0)] => [
              [[dimer_base, dimer_base.atom(:cr)], bond_110_front],
              [[dimer_base, dimer_base.atom(:crb)], position_100_front]
            ],
            [dimer_base, dimer_base.atom(:cl)] => [
              [[aib, aib.atom(:ct)], position_100_cross],
              [[dimer_base, dimer_base.atom(:cr)], bond_100_front],
              [[dimer_base, dimer_base.atom(:clb)], bond_110_cross],
              [[dimer_base, dimer_base.atom(:_cr1)], bond_110_cross]
            ],
            [dimer_base, dimer_base.atom(:clb)] => [
              [[dimer_base, dimer_base.atom(:cl)], bond_110_front],
              [[dimer_base, dimer_base.atom(:_cr1)], position_100_front]
            ],
            [dimer_base, dimer_base.atom(:_cr1)] => [
              [[dimer_base, dimer_base.atom(:cl)], bond_110_front],
              [[dimer_base, dimer_base.atom(:clb)], position_100_front],
            ],
            [veiled_dimer, veiled_dimer.atom(:cr)] => [
              [[ab, ab.atom(:ct)], position_100_cross],
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
              [[aib, aib.atom(:ct)], position_100_cross],
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

      describe '#same? and #same_internals?' do
        before { typical_reaction.reaction.reorganize_children_specs! }
        let(:combiner) { ChunksCombiner.new(typical_reaction) }
        let(:typical_reaction) { dept_symmetric_dimer_formation }
        let(:lateral_reactions) { [dept_small_ab_lateral_sdf] }

        let(:b) { activated_bridge.dup }
        let(:new_target) { [b, b.atom(:ct)] }
        let(:idp_chs) do
          cmb_lateral_reactions.map(&:chunk).select { |ch| ch.is_a?(IndependentChunk) }
        end
        let(:rpts_chs) do
          idp_chs.map { |x| x.replace_target(x.targets.first, new_target) }
        end

        let(:idp_mgr) { described_class.new(typical_reaction, idp_chs, {}) }
        let(:rpts_mgr) { described_class.new(typical_reaction, rpts_chs, {}) }

        it { expect(idp_mgr.same?(rpts_mgr)).to be_truthy }
        it { expect(rpts_mgr.same?(idp_mgr)).to be_truthy }
        it { expect(idp_mgr.same_internals?(rpts_mgr)).to be_truthy }
        it { expect(rpts_mgr.same_internals?(idp_mgr)).to be_truthy }

        let(:cross_idp) do
          idp_chs.select { |ch| ch.relations.map(&:dir) == [:cross] }
        end
        let(:big_mgr1) do
          described_class.new(typical_reaction, idp_chs + rpts_chs + cross_idp, {})
        end
        let(:big_mgr2) do
          described_class.new(typical_reaction, rpts_chs + idp_chs + cross_idp, {})
        end

        it { expect(big_mgr1.same?(idp_mgr)).to be_falsey }
        it { expect(idp_mgr.same?(big_mgr1)).to be_falsey }
        it { expect(big_mgr1.same_internals?(idp_mgr)).to be_falsey }
        it { expect(idp_mgr.same_internals?(big_mgr1)).to be_falsey }

        # chunks are not same because links graphs of merged chunk are not connected
        it { expect(big_mgr1.same?(big_mgr2)).to be_falsey }
        it { expect(big_mgr2.same?(big_mgr1)).to be_falsey }
        it { expect(big_mgr1.same_internals?(big_mgr2)).to be_truthy }
        it { expect(big_mgr2.same_internals?(big_mgr1)).to be_truthy }
      end

      describe '#original?' do
        it { expect(mrg_chunk.original?).to be_falsey }
      end

      describe '#lateral_reaction' do
        it { expect(mrg_chunk.lateral_reaction).to be_a(CombinedLateralReaction) }
        it { expect(mrg_chunk.lateral_reaction).to eq(mrg_chunk.lateral_reaction) }
      end

      describe '#tail_name' do
        it { expect(mrg_chunk.tail_name).to eq('100 cross dimer and 100 cross dimer') }
      end
    end

  end
end
