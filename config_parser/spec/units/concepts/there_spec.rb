require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe There do
      describe "#where" do
        it { on_end.where.should == at_end }
        it { on_middle.where.should == at_middle }
      end

      describe "#specs" do
        it { on_end.specs.should == [dimer_base] }
        it { there_methyl.specs.should == [methyl_on_bridge_base] }
      end

      describe "#description" do
        it { on_end.description.should == 'at end of dimers row' }
        it { there_methyl.description.should == 'chain neighbour methyl' }
      end

      describe "#same?" do
        let(:same) { at_end.concretize(two: dimer.atom(:cl),
                                       one: dimer.atom(:cr)) }
        it { on_end.same?(same).should be_true }
        it { on_end.same?(on_middle).should be_false }
        it { on_middle.same?(on_end).should be_false }
        it { on_end.same?(there_methyl).should be_false }
      end

      describe "#cover?" do
        it { on_end.cover?(on_middle).should be_true }
        it { on_middle.cover?(on_end).should be_false }
        it { there_methyl.cover?(on_end).should be_false }
      end

      describe "#size" do
        it { on_end.size.should == 6 }
        it { on_middle.size.should == 12 }
        it { there_methyl.size.should == 4 }
      end
    end

  end
end
