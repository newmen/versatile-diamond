require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe LateralReaction, visitable: true do
      let(:reaction) { dimer_formation.lateral_duplicate('tail', [on_end]) }
      let(:same) { dimer_formation.lateral_duplicate('same', [on_end]) }
      let(:middle) { dimer_formation.lateral_duplicate('middle', [on_middle]) }
      let(:other) { dimer_formation.lateral_duplicate(
        'other', [on_end, there_methyl]) }

      describe "#theres" do
        it { reaction.theres.should == [on_end] }
        it { other.theres.should == [on_end, there_methyl] }
      end

      describe "#reverse" do
        subject { reaction.reverse }
        it { should be_a(described_class) }

        # TODO: check reversed theres
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
        it { reaction.size.should == 14.34 }
        it { other.size.should == 18.34 }
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
