require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Where, visitable: true do
      describe "#specs" do
        it { at_end.specs.should == [dimer_base] }
        it { at_middle.specs.should == [dimer_base, dimer_base] }
        it { near_methyl.specs.should == [methyl_on_bridge_base] }
      end

      describe "#description" do
        it { at_end.description.should == 'at end of dimers row' }
      end

      describe "#parents" do
        it { at_end.parents.should be_empty }
        it { at_middle.parents.should == [at_end] }
      end

      describe "#concretize" do
        it { near_methyl.concretize(target: bridge.atom(:ct)).
          should be_a(There) }

        # TODO: check positions
      end

      it_behaves_like "visitable" do
        subject { at_end }
      end
    end

  end
end
