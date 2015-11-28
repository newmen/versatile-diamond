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
          it { expect(chunk_residual).to be_a(ChunkResidual) }
          it { expect(chunk_residual.links).to match_graph(rest_links) }
        end

        it_behaves_like :check_subtract do
          let(:chunk_residual) { residual }
          let(:ab) { middle_lateral_df.source.first }
          let(:aib) { middle_lateral_df.source.last }

          let(:env_specs) { middle_lateral_df.theres.flat_map(&:env_specs).uniq }
          let(:dmr1) { env_specs.last }
          let(:dmr2) { env_specs.first }

          let(:rest_links) do
            {
              [ab, ab.atom(:ct)] => [
                [[dmr1, dmr1.atom(:cl)], position_100_cross],
                [[dmr2, dmr2.atom(:cl)], position_100_cross],
              ],
              [aib, aib.atom(:ct)] => [
                [[dmr1, dmr1.atom(:cr)], position_100_cross],
                [[dmr2, dmr2.atom(:cr)], position_100_cross],
              ],
              [dmr1, dmr1.atom(:cr)] => [
                [[aib, aib.atom(:ct)], position_100_cross],
                [[dmr1, dmr1.atom(:cl)], bond_100_front],
                [[dmr1, dmr1.atom(:crb)], bond_110_cross],
                [[dmr1, dmr1.atom(:_cr0)], bond_110_cross]
              ],
              [dmr1, dmr1.atom(:crb)] => [
                [[dmr1, dmr1.atom(:cr)], bond_110_front],
                [[dmr1, dmr1.atom(:_cr0)], position_100_front]
              ],
              [dmr1, dmr1.atom(:_cr0)] => [
                [[dmr1, dmr1.atom(:cr)], bond_110_front],
                [[dmr1, dmr1.atom(:crb)], position_100_front]
              ],
              [dmr1, dmr1.atom(:cl)] => [
                [[ab, ab.atom(:ct)], position_100_cross],
                [[dmr1, dmr1.atom(:cr)], bond_100_front],
                [[dmr1, dmr1.atom(:clb)], bond_110_cross],
                [[dmr1, dmr1.atom(:_cr1)], bond_110_cross]
              ],
              [dmr1, dmr1.atom(:clb)] => [
                [[dmr1, dmr1.atom(:cl)], bond_110_front],
                [[dmr1, dmr1.atom(:_cr1)], position_100_front]
              ],
              [dmr1, dmr1.atom(:_cr1)] => [
                [[dmr1, dmr1.atom(:cl)], bond_110_front],
                [[dmr1, dmr1.atom(:clb)], position_100_front],
              ],
            }
          end
        end

        it_behaves_like :check_subtract do
          let(:chunk_residual) { ewb_chunk - end_chunk }
          let(:ab) { ewb_lateral_df.source.first }
          let(:aib) { ewb_lateral_df.source.last }

          let(:env_specs) { ewb_lateral_df.theres.flat_map(&:env_specs).uniq }
          let(:br) { env_specs.first }
          let(:dmr) { env_specs.last }

          let(:rest_links) do
            {
              [ab, ab.atom(:ct)] => [
                [[dmr, dmr.atom(:cl)], position_100_cross],
              ],
              [aib, aib.atom(:ct)] => [
                [[dmr, dmr.atom(:cr)], position_100_cross],
                [[br, br.atom(:ct)], position_100_front],
              ],
              [br, br.atom(:ct)] => [
                [[aib, aib.atom(:ct)], position_100_front],
                [[br, br.atom(:cr)], bond_110_cross],
                [[br, br.atom(:cl)], bond_110_cross],
              ],
              [br, br.atom(:cr)] => [
                [[br, br.atom(:ct)], bond_110_front],
                [[br, br.atom(:cl)], position_100_front],
              ],
              [br, br.atom(:cl)] => [
                [[br, br.atom(:ct)], bond_110_front],
                [[br, br.atom(:cr)], position_100_front],
              ]
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
