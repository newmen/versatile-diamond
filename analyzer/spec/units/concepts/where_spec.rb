require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Where do
      describe "#specs" do
        it { at_end.specs.should == [dimer] }
        it { at_middle.specs.should == [dimer] }
        it { near_methyl.specs.should == [methyl_on_bridge] }
      end

      describe "#description" do
        it { at_end.description.should == 'at end of dimers row' }
      end

      it_behaves_like "check specs after swap_source" do
        subject { at_end }
        let(:method) { :specs }
      end

      describe "#parents" do
        it { at_end.parents.should be_empty }
        it { at_middle.parents.should == [at_end] }
      end

      describe "#concretize" do
        it { near_methyl.concretize(target: [bridge, bridge.atom(:ct)]).
          should be_a(There) }

        # TODO: check positions
      end

      describe "#used_keynames_of" do
        it { at_end.used_keynames_of(dimer).size.should == 2 }
        it { at_end.used_keynames_of(dimer).should include(:cr, :cl) }

        it { at_middle.used_keynames_of(dimer).size.should == 2 }
        it { at_middle.used_keynames_of(dimer).should include(:cr, :cl) }

        it { near_methyl.used_keynames_of(methyl_on_bridge).should == [:cb] }
      end

      it_behaves_like "visitable" do
        subject { at_end }
      end
    end

  end
end
