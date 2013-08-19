require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe There do
      describe "#specs" do
        it { on_end.specs.should == [dimer] }
        it { there_methyl.specs.should == [methyl_on_bridge] }
      end

      describe "#description" do
        it { on_end.description.should == 'at end of dimers row' }
        it { there_methyl.description.should == 'chain neighbour methyl' }
      end
    end

  end
end
