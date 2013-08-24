require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe There do
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
    end

  end
end
