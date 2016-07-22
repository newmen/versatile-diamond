require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe Chunk, type: :organizer do
      let(:residual) { middle_chunk - end_chunk }

      describe '#replace_target' do
        before { dept_end_lateral_df.send(:store_parent, dept_dimer_formation) }
        subject { end_chunk.replace_target(from, to) }
        let(:from) { end_chunk.targets.first }
        let(:to) { [extra_activated_bridge, extra_activated_bridge.atom(:ct)] }
        it { expect(subject).to be_a(TargetReplacedChunk) }
        it { expect(subject).not_to eq(end_chunk) }
      end

      describe '#parents && #root?' do
        it { expect(middle_chunk.parents).to be_empty }

        describe '#store_parent' do
          before { middle_chunk.store_parent(end_chunk) }
          it { expect(middle_chunk.parents).to eq([end_chunk]) }
        end
      end

      describe '#lateral_reaction' do
        it { expect(end_chunk.lateral_reaction).to eq(dept_end_lateral_df) }
        it { expect(middle_chunk.lateral_reaction).to eq(dept_middle_lateral_df) }
      end

      describe '#typical_reaction' do
        it { expect(end_chunk.typical_reaction).to be_nil }

        describe 'after store parent' do
          before { dept_end_lateral_df.send(:store_parent, dept_dimer_formation) }
          it { expect(end_chunk.typical_reaction).to eq(dept_dimer_formation) }
        end
      end

      describe '#full_rate' do
        it { expect(end_chunk.full_rate).to eq(dept_end_lateral_df.full_rate) }
      end

      describe '#targets' do
        shared_examples_for :check_targets do
          let(:ab) { reaction.source.first }
          let(:aib) { reaction.source.last }
          let(:targets) { [[ab, ab.atom(:ct)], [aib, aib.atom(:ct)]] }
          it { expect(subject.targets.to_a).to match_array(targets) }
        end

        it_behaves_like :check_targets do
          subject { end_chunk }
          let(:reaction) { end_lateral_df }
        end

        it_behaves_like :check_targets do
          subject { ewb_chunk }
          let(:reaction) { ewb_lateral_df }
        end
      end

      describe '#<=>' do
        it { expect(end_chunk <=> middle_chunk).to eq(-1) }
        it { expect(middle_chunk <=> end_chunk).to eq(1) }

        it { expect(residual <=> end_chunk).to eq(-1) }
        it { expect(end_chunk <=> residual).to eq(1) }
      end

      describe '#-' do
        shared_examples_for :check_subtract do
          let(:raw_kn_graph) do
            raw_k_proc = -> sa { [sa.first, sa.first.keyname(sa.last)] }
            chunk_residual.links.each_with_object({}) do |(key, rels), acc|
              acc[raw_k_proc[key]] = rels.map { |sa, r| [raw_k_proc[sa], r] }
            end
          end

          let(:good_kn_graph) do
            specs_to_i = {}
            max_index_for = -> spec do
              i = specs_to_i.select { |s, _| s.name == spec.name }.map(&:last).max
              i ? i + 1 : 0
            end

            keys = raw_kn_graph.keys +
              raw_kn_graph.values.flat_map { |rels| rels.map(&:first) }

            other_keys = -> sk { keys.reject { |x| x == sk } }
            has_keyname_same = -> sk { other_keys[sk].any? { |_, k| k == sk.last } }
            has_spec_same = -> sk do
              spec = sk.first
              other_keys[sk].any? { |s, _| s != spec && s.name == spec.name }
            end

            alias_proc = -> sk do
              spec, keyname = sk
              if has_spec_same[sk]
                specs_to_i[spec] ||= max_index_for[spec]
                :"#{spec.name}__#{specs_to_i[spec]}__#{keyname}"
              elsif has_keyname_same[sk]
                :"#{spec.name}__#{keyname}"
              else
                keyname
              end
            end

            raw_kn_graph.each_with_object({}) do |(spec_keyname, rels), acc|
              acc[alias_proc[spec_keyname]] = rels.map { |sk, r| [alias_proc[sk], r] }
            end
          end

          it { expect(good_kn_graph).to match_graph(rest_links) }
          it { expect(chunk_residual).to be_a(ChunkResidual) }
        end

        it_behaves_like :check_subtract do
          let(:chunk_residual) { residual }

          let(:ab) { :'bridge(ct: *)__ct' }
          let(:aib) { :'bridge(ct: *, ct: i)__ct' }
          let(:d1l) { :'dimer()__0__cl' }
          let(:d1r) { :'dimer()__0__cr' }
          let(:d11) { :'dimer()__0__clb' }
          let(:d12) { :'dimer()__0___cr1' }
          let(:d13) { :'dimer()__0__crb' }
          let(:d14) { :'dimer()__0___cr0' }
          let(:d2l) { :'dimer()__1__cl' }
          let(:d2r) { :'dimer()__1__cr' }
          let(:rest_links) do
            {
              ab => [[d1l, position_100_cross], [d2l, position_100_cross]],
              aib => [[d1r, position_100_cross], [d2r, position_100_cross]],
              d1l => [
                [ab, position_100_cross],
                [d1r, bond_100_front], [d11, bond_110_cross], [d12, bond_110_cross]
              ],
              d11 => [[d1l, bond_110_front], [d12, position_100_front]],
              d12 => [[d1l, bond_110_front], [d11, position_100_front]],
              d1r => [
                [aib, position_100_cross],
                [d1l, bond_100_front], [d13, bond_110_cross], [d14, bond_110_cross]
              ],
              d13 => [[d1r, bond_110_front], [d14, position_100_front]],
              d14 => [[d1r, bond_110_front], [d13, position_100_front]]
            }
          end
        end

        it_behaves_like :check_subtract do
          let(:chunk_residual) { ewb_chunk - end_chunk }

          let(:aib) { :'bridge(ct: *, ct: i)__ct' }
          let(:ab) { :'bridge(ct: *)__ct' }
          let(:bt) { :'bridge()__ct' }
          let(:bl) { :'bridge()__cl' }
          let(:br) { :'bridge()__cr' }
          let(:dl) { :'dimer()__cl' }
          let(:dr) { :'dimer()__cr' }
          let(:rest_links) do
            {
              ab => [[dl, position_100_cross]],
              aib => [[dr, position_100_cross], [bt, position_100_front]],
              bt => [
                [aib, position_100_front], [br, bond_110_cross], [bl, bond_110_cross]
              ],
              br => [[bt, bond_110_front], [bl, position_100_front]],
              bl => [[bt, bond_110_front], [br, position_100_front]]
            }
          end
        end
      end

      describe 'equality' do
        let(:other) do
          concept = dimer_formation.lateral_duplicate('copy', [on_end])
          DependentLateralReaction.new(concept).chunk
        end

        describe '#==' do
          it { expect(end_chunk == end_chunk).to be_truthy }
          it { expect(end_chunk == other).to be_falsey }
          it { expect(other == end_chunk).to be_falsey }
          it { expect(end_chunk == residual).to be_falsey }
          it { expect(residual == end_chunk).to be_falsey }
        end

        describe '#same?' do
          it { expect(end_chunk.same?(other)).to be_truthy }
          it { expect(other.same?(end_chunk)).to be_truthy }

          it { expect(end_chunk.same?(middle_chunk)).to be_falsey }
          it { expect(middle_chunk.same?(end_chunk)).to be_falsey }

          it { expect(end_chunk.same?(residual)).to be_truthy }
          it { expect(residual.same?(end_chunk)).to be_truthy }
        end
      end

      describe '#tail_name' do
        it { expect(end_chunk.tail_name).to eq(on_end.description) }
        it { expect(middle_chunk.tail_name).to eq(on_middle.description) }
      end

      describe '#original?' do
        it { expect(end_chunk.original?).to be_truthy }
      end
    end

  end
end
