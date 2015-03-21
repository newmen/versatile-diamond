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

      describe '#<=>' do
        it { expect(end_chunk <=> middle_chunk).to eq(-1) }
        it { expect(middle_chunk <=> end_chunk).to eq(1) }

        it { expect(residual <=> end_chunk).to eq(-1) }
        it { expect(end_chunk <=> residual).to eq(1) }
      end

      describe '#<' do
        it { expect(end_chunk < middle_chunk).to be_truthy }
        it { expect(middle_chunk < end_chunk).to be_falsey }

        it { expect(residual < end_chunk).to be_falsey }
        it { expect(end_chunk < residual).to be_truthy }
      end

      describe '#<=' do
        it { expect(end_chunk <= middle_chunk).to be_truthy }
        it { expect(middle_chunk <= end_chunk).to be_falsey }

        it { expect(end_chunk <= residual).to be_truthy }
        it { expect(residual <= end_chunk).to be_falsey }
      end

      describe '#-' do
        it { expect(residual).to be_a(ChunkResidual) }

        let(:ab) { middle_lateral_df.source.first }
        let(:aib) { middle_lateral_df.source.last }
        let(:rest_links) do
          {
            [ab, ab.atom(:ct)] => [
              # [[ab, ab.atom(:cr)], bond_110_cross],
              # [[ab, ab.atom(:cl)], bond_110_cross],
              # [[aib, aib.atom(:ct)], position_100_front],
              [[dimer, dimer.atom(:cl)], position_100_cross],
              [[dimer_dup, dimer_dup.atom(:cl)], position_100_cross],
            ],
            [aib, aib.atom(:ct)] => [
              # [[aib, aib.atom(:cr)], bond_110_cross],
              # [[aib, aib.atom(:cl)], bond_110_cross],
              # [[ab, ab.atom(:ct)], position_100_front],
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

        it { expect(residual.links).to match_graph(rest_links) }
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

          it { expect(end_chunk.same?(residual)).to be_falsey }
          it { expect(residual.same?(end_chunk)).to be_falsey }
        end
      end
    end

  end
end
