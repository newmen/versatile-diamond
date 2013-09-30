require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Bond do
      describe "#self.[]" do
        it "if face and dir the same then returns the same instance" do
          {
            {} => free_bond,
            { face: 110, dir: :front } => bond_110_front,
            { face: 110, dir: :cross } => bond_110_cross
          }.each do |hash, bond|
            Bond[hash].should == bond
          end
        end
      end

      describe "#face" do
        it { free_bond.face.should be_nil }
        it { bond_110_front.face.should == 110 }
        it { bond_110_cross.face.should == 110 }
        it { bond_100_front.face.should == 100 }
        it { bond_100_cross.face.should == 100 }
      end

      describe "#dir" do
        it { free_bond.dir.should be_nil }
        it { bond_110_front.dir.should == :front }
        it { bond_110_cross.dir.should == :cross }
        it { bond_100_front.dir.should == :front }
        it { bond_100_cross.dir.should == :cross }
      end

      describe "#same?" do
        it { free_bond.same?(bond_110_front).should be_true }
        it { bond_110_front.same?(free_bond).should be_true }
      end
    end

  end
end
