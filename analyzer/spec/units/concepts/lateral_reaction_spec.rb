require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe LateralReaction do
      let(:reaction) { dimer_formation.lateral_duplicate('tail', [on_end]) }
      let(:same) { dimer_formation.lateral_duplicate('same', [on_end]) }
      let(:middle) { dimer_formation.lateral_duplicate('middle', [on_middle]) }
      let(:other) do
        dimer_formation.lateral_duplicate('other', [on_end, there_methyl])
      end
      let(:target_dimer) { reaction.reverse.source.first }

      describe '#theres' do
        it { expect(reaction.theres.size).to eq(1) }
        it { expect(reaction.theres.first.same?(on_end)).to be_true }

        it { expect(other.theres.size).to eq(2) }
        it { expect(other.theres.first.same?(on_end)).to be_true }
        it { expect(other.theres.last.same?(there_methyl)).to be_true }
      end

      describe '#reverse' do
        subject { reaction.reverse }
        let(:there) { subject.theres.first }

        it { should be_a(described_class) }

        describe 'theres reversed too' do
          it { expect(there.positions).to eq({
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

          it { expect(there.positions).to eq({
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

          it { expect(subject.used_keynames_of(first_bridge)).to match_array([:ct]) }
          it { expect(subject.used_keynames_of(second_bridge)).to match_array([:ct]) }
        end

        describe 'reverse' do
          subject { reaction.reverse.used_keynames_of(target_dimer) }
          it { expect(subject.size).to eq(2) }
          it { should include(:cr, :cl) }
        end
      end

      describe '#same?' do
        it { expect(reaction.same?(same)).to be_true }
        it { expect(reaction.same?(middle)).to be_false }
        it { expect(middle.same?(reaction)).to be_false }

        it { expect(reaction.same?(dimer_formation)).to be_false }
      end

      describe '#organize_dependencies!' do
        before(:each) do
          reactions = [reaction, middle, other]
          reaction.organize_dependencies!(reactions)
          middle.organize_dependencies!(reactions)
          other.organize_dependencies!(reactions)
        end

        it { expect(reaction.more_complex).to match_array([middle]) }
        it { expect(middle.more_complex).to be_empty }
        it { expect(other.more_complex).to be_empty }
      end

      describe '#size' do
        it { expect(reaction.size.round(2)).to eq(12.81) }
        it { expect(other.size.round(2)).to eq(16.81) }
      end

      it_behaves_like 'visitable' do
        subject { reaction }
      end

      describe '#wheres' do
        it { expect(reaction.wheres).to match_array([at_end]) }

        it { expect(other.wheres.size).to eq(2) }
        it { expect(other.wheres).to include(at_end, near_methyl) }
      end
    end

  end
end
