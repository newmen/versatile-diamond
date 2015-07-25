require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe Chunk, type: :organizer do
      let(:residual) { middle_chunk - end_chunk }

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

      describe '#mapped_targets' do
        it_behaves_like :check_mapped_targets do
          let(:reaction) { dept_end_lateral_df }
          let(:chunk) { end_chunk }
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
            }
          end
        end

        it_behaves_like :check_subtract do
          let(:chunk_residual) { ewb_chunk - end_chunk }
          let(:ab) { ewb_lateral_df.source.first }
          let(:aib) { ewb_lateral_df.source.last }
          let(:rest_links) do
            {
              [ab, ab.atom(:ct)] => [
                [[dimer, dimer.atom(:cl)], position_100_cross],
              ],
              [aib, aib.atom(:ct)] => [
                [[dimer, dimer.atom(:cr)], position_100_cross],
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
