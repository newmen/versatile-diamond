require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe AtomReference do
      let(:ref) { AtomReference.new(ethylene_base, :c1) }

      describe "#name" do
        it { ref.name.should == :C }
      end

      describe "#valence" do
        it { ref.valence.should == 2 }
      end

      describe "#same?" do
        it { c1.same?(ref).should be_true }
        it { ref.same?(c1).should be_true }
        it { ref.same?(ref.dup).should be_true }
      end

      describe "#actives" do
        it { ref.actives.should == 0 }
      end

      describe "#diff" do
        it { ref.diff(ref.dup).should == [] }
        it { ref.diff(c).should == [] }
        it { ref.diff(activated_c).should == [] }
        it { ref.diff(unfixed_c).should == [:unfixed] }
        it { ref.diff(unfixed_activated_c).should == [:unfixed] }
        it { AtomReference.new(bridge_base, :ct).diff(activated_incoherent_cd).
          should == [:incoherent] }
        it { AtomReference.new(bridge_base, :ct).diff(incoherent_cd).
          should == [:incoherent] }
      end

      describe "#relations_in" do
        it { bridge.atom(:cr).relations_in(bridge).size.should == 4 }
        it { bridge.atom(:cr).relations_in(bridge).should include(
            bond_110_cross, bond_110_cross, bond_110_front, position_100_front
          ) }
      end

      it_behaves_like "#lattice" do
        let(:target) { c1 }
        let(:reference) { ref }
      end

    end

  end
end
