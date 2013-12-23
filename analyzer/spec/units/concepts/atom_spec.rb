require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Atom do
      describe "#self.is_hydrogen?" do
        it { Atom.is_hydrogen?(h).should be_true }
        it { Atom.is_hydrogen?(c).should be_false }
      end

      describe "#valence" do
        it { h.valence.should == 1 }
        it { c.valence.should == 4 }
      end

      describe "#original_valence" do
        it { h.original_valence.should == 1 }
        it { c.original_valence.should == 4 }
      end

      describe "#lattice" do
        it "set and get lattice" do
          cd.lattice.should == diamond
        end
      end

      describe "#same?" do
        it { c.same?(h).should be_false }
        it { c.same?(c.dup).should be_true }
        it { c.same?(cd).should be_false }
        it { cd.same?(cd.dup).should be_true  }
      end

      describe "#actives" do
        it { h.actives.should == 0 }
        it { c.actives.should == 0 }
      end

      describe "#diff" do
        it { c.diff(c.dup).should == [] }
        it { c.diff(unfixed_c).should == [:unfixed] }
        it { c.diff(unfixed_activated_c).should == [:unfixed] }
        it { cd.diff(incoherent_cd).should == [:incoherent] }
        it { cd.diff(activated_incoherent_cd).should == [:incoherent] }
      end

      describe "#relations_in" do
        it { cd.relations_in(bridge).should == bridge.links[cd] }
        it { cd.relations_in(bridge).object_id.
          should_not == bridge.links[cd].object_id }

        it { cd.relations_in(bridge).size.should == 2 }
      end
    end

  end
end
