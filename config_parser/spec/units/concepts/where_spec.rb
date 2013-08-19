require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Where do
      describe "#specs" do
        it { at_end.specs.should == [dimer] }
        it { near_methyl.specs.should == [methyl_on_bridge] }
      end

      describe "#description" do
        it { at_end.description.should == 'at end of dimers row' }
        it { near_methyl.description.should == 'chain neighbour methyl' }
      end
    end

  end
end
