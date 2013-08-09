require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Atom do
      let(:hydrogen) { Atom.new('H', 1) }
      let(:carbon) { Atom.new('C', 4) }

      let(:diamond) { Lattice.new(:d, 'cap') }
      let(:dicar) do
        c = carbon.dup
        c.lattice = diamond; c
      end

      describe "#self.is_hydrogen?" do
        it { Atom.is_hydrogen?(hydrogen).should be_true }
        it { Atom.is_hydrogen?(carbon).should be_false }
      end

      describe "#valence" do
        it { hydrogen.valence.should == 1 }
        it { carbon.valence.should == 4 }
      end

      describe "#lattice" do
        it "set and get lattice" do
          dicar.lattice.should == diamond
        end
      end

      describe "#same?" do
        it { carbon.same?(hydrogen).should be_false }
        it { carbon.same?(carbon.dup).should be_true }
        it { carbon.same?(dicar).should be_false }
        it { dicar.same?(dicar.dup).should be_true  }
      end
    end

  end
end
