require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Atom do
      let(:hydrogen) { Atom.new('H', 1) }
      let(:carbon) { Atom.new('C', 4) }

      describe "#self.is_hydrogen?" do
        it { Atom.is_hydrogen?(hydrogen).should be_true }
        it { Atom.is_hydrogen?(carbon).should be_false }
      end

      describe "#valence" do
        it { hydrogen.valence.should == 1 }
        it { carbon.valence.should == 4 }
      end

      describe "#lattice" do
        let(:diamond) { Lattice.new(:d, 'cap') }
        it "set and get lattice" do
          carbon.lattice = diamond
          carbon.lattice.should == diamond
        end
      end
    end

  end
end
