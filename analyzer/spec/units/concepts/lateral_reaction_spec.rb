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
        subject { reaction.reverse }
        let(:there) { subject.theres.first }

        it { should be_a(described_class) }

        describe 'theres reversed too' do
          it { expect(there.positions).to match_graph({
              [target_dimer, target_dimer.atom(:cr)] => [
                [[dimer, dimer.atom(:cl)], position_100_cross]
              ],
              [target_dimer, target_dimer.atom(:cl)] => [
                [[dimer, dimer.atom(:cr)], position_100_cross]
              ],
            }) }
        end

        describe "reverced atom haven't lattice" do
          subject { original.reverse }
          let(:curr_mid) do
            at_middle.concretize(
              one: [extended_dimer, extended_dimer.atom(:cl)],
              two: [extended_dimer, extended_dimer.atom(:cr)])
          end
          let(:original) do
            methyl_incorporation.reverse.lateral_duplicate('tail', [curr_mid])
          end
          let(:moeb) { subject.source.first }
          let(:dim) { subject.source.last }

          it { expect(there.positions).to match_graph({
              [moeb, moeb.atom(:cb)] => [
                [[dimer, dimer.atom(:cl)], position_100_cross],
                [[dimer, dimer.atom(:cl)], position_100_cross],
              ],
              [dim, dim.atom(:cl)] => [
                [[dimer, dimer.atom(:cr)], position_110_front],
              ],
              [dim, dim.atom(:cr)] => [
                [[dimer, dimer.atom(:cr)], position_110_front],
              ],
            }) }
        end
      end

      describe '#used_keynames_of' do
        describe 'forward' do
          subject { reaction }
          let(:first_bridge) { subject.source.first }
          let(:second_bridge) { subject.source.last }

          it { expect(subject.used_keynames_of(first_bridge)).to eq([:ct]) }
          it { expect(subject.used_keynames_of(second_bridge)).to eq([:ct]) }
        end

        describe 'reverse' do
          subject { reaction.reverse.used_keynames_of(target_dimer) }
          it { should match_array([:cr, :cl]) }
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

      describe '#size' do
        it { expect(reaction.size.round(2)).to eq(12.81) }
        it { expect(other.size.round(2)).to eq(16.81) }
      end

      it_behaves_like 'visitable' do
        subject { reaction }
      end
    end

  end
end
