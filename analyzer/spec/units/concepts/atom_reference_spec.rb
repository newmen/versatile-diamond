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

      describe "#original_valence" do
        it { ref.original_valence.should == 4 }
      end

      describe "#same?" do
        it { c1.same?(ref).should be_true }
        it { ref.same?(c1).should be_true }
        it { ref.same?(ref.dup).should be_true }
      end

      describe "#actives" do
        it { ref.actives.should == 0 }
      end

      describe "#monovalents" do
        it { ref.monovalents.should be_empty }
      end

      describe "#incoherent? and #unfixed?" do
        it { ref.incoherent?.should be_false }
        it { ref.unfixed?.should be_false }
      end

      describe "#diff" do
        it { ref.diff(ref.dup).should be_empty }
        it { ref.diff(c).should be_empty }
        it { ref.diff(activated_c).should be_empty }
        it { ref.diff(unfixed_c).should =~ [:unfixed] }
        it { ref.diff(unfixed_activated_c).should =~ [:unfixed] }
        it { AtomReference.new(bridge_base, :ct).diff(activated_incoherent_cd).
          should =~ [:incoherent] }
        it { AtomReference.new(bridge_base, :ct).diff(incoherent_cd).
          should =~ [:incoherent] }
      end

      describe "#relations_in" do
        it { bridge.atom(:cr).relations_in(bridge).size.should == 4 }
      end

      it_behaves_like "#lattice" do
        let(:target) { c1 }
        let(:reference) { ref }
      end

    end

  end
end
