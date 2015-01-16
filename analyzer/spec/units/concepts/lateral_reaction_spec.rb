require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe LateralReaction do
      let(:reaction) { end_lateral_df }
      let(:same) { dimer_formation.lateral_duplicate('same', [on_end]) }
      let(:middle) { middle_lateral_df }
      let(:other) do
        dimer_formation.lateral_duplicate('other', [on_end, there_methyl])
      end
      let(:target_dimer) { reaction.reverse.source.first }

      describe '#theres' do
        it { expect(reaction.theres.size).to eq(1) }
        it { expect(reaction.theres.first.same?(on_end)).to be_truthy }

        it { expect(other.theres.size).to eq(2) }
        it { expect(other.theres.first.same?(on_end)).to be_truthy }
        it { expect(other.theres.last.same?(there_methyl)).to be_truthy }
      end

      describe '#reverse' do
        describe 'theres reversed too' do
          subject { reaction.reverse }
          let(:there) { subject.theres.first }
          let(:positions) do
            {
              [target_dimer, target_dimer.atom(:cr)] => [
                [[dimer, dimer.atom(:cl)], position_100_cross]
              ],
              [target_dimer, target_dimer.atom(:cl)] => [
                [[dimer, dimer.atom(:cr)], position_100_cross]
              ],
            }
          end

          it { should be_a(described_class) }
          it { expect(there.links).to match_graph(positions) }
        end

        describe "reverced atom haven't lattice" do
          # could not be, just image this reaction!
          let(:ed) { mi_product.first }
          let(:curr_mid) do
            at_middle.concretize(one: [ed, ed.atom(:cl)], two: [ed, ed.atom(:cr)])
          end
          let(:original) do
            methyl_incorporation.reverse.lateral_duplicate('tail', [curr_mid])
          end

          it { expect { original.reverse }.
            to raise_error(described_class::ReversingError) }
        end
      end

      describe '#used_atoms_of' do
        describe 'forward' do
          subject { reaction }
          let(:first) { subject.source.first }
          let(:second) { subject.source.last }
          it { expect(subject.used_atoms_of(first)).to eq([first.atom(:ct)]) }
          it { expect(subject.used_atoms_of(second)).to eq([second.atom(:ct)]) }
        end

        describe 'reverse' do
          subject { reaction.reverse.used_atoms_of(target_dimer) }
          it { should match_array([:cr, :cl].map { |a| target_dimer.atom(a) }) }
        end
      end

      describe '#same?' do
        it { expect(reaction.same?(same)).to be_truthy }
        it { expect(reaction.same?(middle)).to be_falsey }
        it { expect(middle.same?(reaction)).to be_falsey }

        it { expect(reaction.same?(dimer_formation)).to be_falsey }
      end

      describe '#cover?' do
        it { expect(reaction.cover?(middle)).to be_truthy }
        it { expect(reaction.cover?(other)).to be_truthy }
      end
    end

  end
end
