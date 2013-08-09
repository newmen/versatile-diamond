require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe AtomReference, type: :latticed_ref_atom do
      let(:c1) { Atom.new('C', 4) }
      let(:c2) { c1.dup }
      let(:bond) { Bond[face: nil, dir: nil] }
      let(:ethylene) do
        spec = Spec.new(:ethylene, c1: c1, c2: c2)
        spec.link(c1, c2, bond)
        spec.link(c1, c2, bond)
        spec
      end
      let(:ref) { AtomReference.new(ethylene, :c1) }

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
