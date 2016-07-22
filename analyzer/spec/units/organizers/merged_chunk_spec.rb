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

        let(:merged_links) do
          spec_name_proc = -> sa { sa.first.name }
          translate_to_keyname_graph(mrg_chunk.links, spec_name_proc) do |s, a|
            s.keyname(a)
          end
        end

        let(:links) do
          {
            :'bridge(ct: *)__ct' => [
              [:dimer__0__cl, position_100_cross], [:dimer__1__cl, position_100_cross]
            ],
            :'bridge(ct: *, ct: i)__ct' => [
              [:dimer__0__cr, position_100_cross], [:dimer__1__cr, position_100_cross]
            ],
            :dimer__0__cr => [
              [:dimer__0__crb, bond_110_cross], [:dimer__0___cr0, bond_110_cross],
              [:dimer__0__cl, bond_100_front],
              [:"bridge(ct: *, ct: i)__ct", position_100_cross]
            ],
            :dimer__0__crb => [
              [:dimer__0__cr, bond_110_front], [:dimer__0___cr0, position_100_front]
            ],
            :dimer__0___cr0 => [
              [:dimer__0__cr, bond_110_front], [:dimer__0__crb, position_100_front]
              ],
            :dimer__0__cl => [
              [:dimer__0__clb, bond_110_cross], [:dimer__0___cr1, bond_110_cross],
              [:dimer__0__cr, bond_100_front],
              [:"bridge(ct: *)__ct", position_100_cross]
            ],
            :dimer__0__clb => [
              [:dimer__0__cl, bond_110_front], [:dimer__0___cr1, position_100_front]
            ],
            :dimer__0___cr1 => [
              [:dimer__0__cl, bond_110_front], [:dimer__0__clb, position_100_front]
            ],
            :dimer__1__cr => [
              [:dimer__1__crb, bond_110_cross], [:dimer__1___cr0, bond_110_cross],
              [:dimer__1__cl, bond_100_front],
              [:"bridge(ct: *, ct: i)__ct", position_100_cross]
            ],
            :dimer__1__crb => [
              [:dimer__1__cr, bond_110_front], [:dimer__1___cr0, position_100_front]
            ],
            :dimer__1___cr0 => [
              [:dimer__1__cr, bond_110_front], [:dimer__1__crb, position_100_front]
            ],
            :dimer__1__cl => [
              [:dimer__1__clb, bond_110_cross], [:dimer__1___cr1, bond_110_cross],
              [:dimer__1__cr, bond_100_front],
              [:"bridge(ct: *)__ct", position_100_cross]
            ],
            :dimer__1__clb => [
              [:dimer__1__cl, bond_110_front], [:dimer__1___cr1, position_100_front]
            ],
            :dimer__1___cr1 => [
              [:dimer__1__cl, bond_110_front], [:dimer__1__clb, position_100_front]
            ]
          }
        end

        it { expect(merged_links).to match_graph(links) }
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
