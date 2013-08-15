require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe AtomReference, latticed_ref_atom: true do
      let(:ref) { AtomReference.new(ethylene_base, :c1) }

      describe "#valence" do
        it { ref.valence.should == 2 }
      end

      describe "#same?" do
        it { c1.same?(ref).should be_true }
        it { ref.same?(c1).should be_true }
        it { ref.same?(ref.dup).should be_true }
      end

      it_behaves_like "#lattice" do
        let(:target) { c1 }
        let(:reference) { ref }
      end

    end

  end
end
