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

      describe "#theres" do
        it { reaction.theres.size.should == 1 }
        it { reaction.theres.first.same?(on_end).should be_true }

        it { other.theres.size.should == 2 }
        it { other.theres.first.same?(on_end).should be_true }
        it { other.theres.last.same?(there_methyl).should be_true }
      end

      describe "#reverse" do
        subject { reaction.reverse }
        let(:there) { subject.theres.first }

        it { should be_a(described_class) }

        describe "theres reversed too" do
          it { there.positions.should == {
              [target_dimer, target_dimer.atom(:cr)] => [
                [[dimer, dimer.atom(:cl)], position_100_cross]
              ],
              [target_dimer, target_dimer.atom(:cl)] => [
                [[dimer, dimer.atom(:cr)], position_100_cross]
              ],
            } }
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

          it { there.positions.should == {
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
            } }
        end
      end

      describe "#used_keynames_of" do
        describe "forward" do
          subject { reaction }
          let(:first_bridge) { subject.source.first }
          let(:second_bridge) { subject.source.last }

          it { subject.used_keynames_of(first_bridge).should == [:ct] }
          it { subject.used_keynames_of(second_bridge).should == [:ct] }
        end

        describe "reverse" do
          subject { reaction.reverse.used_keynames_of(target_dimer) }
          it { subject.size.should == 2 }
          it { should include(:cr, :cl) }
        end
      end

      describe "#same?" do
        it { reaction.same?(same).should be_true }
        it { reaction.same?(middle).should be_false }
        it { middle.same?(reaction).should be_false }

        it { reaction.same?(dimer_formation).should be_false }
      end

      describe "#organize_dependencies!" do
        before(:each) do
          reactions = [reaction, middle, other]
          reaction.organize_dependencies!(reactions)
          middle.organize_dependencies!(reactions)
          other.organize_dependencies!(reactions)
        end

        it { reaction.more_complex.should == [middle] }
        it { middle.more_complex.should be_empty }
        it { other.more_complex.should be_empty }
      end

      describe "#size" do
        it { reaction.size.should == 14.09 }
        it { other.size.should == 18.09 }
      end

      it_behaves_like "visitable" do
        subject { reaction }
      end

      describe "#wheres" do
        it { reaction.wheres.should == [at_end] }

        it { other.wheres.size.should == 2 }
        it { other.wheres.should include(at_end, near_methyl) }
      end
    end

  end
end
