require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Bond do
      let(:free_bond) { Bond[face: nil, dir: nil] }
      let(:bond_110) { Bond[face: 110, dir: :front] }

      describe "#self.[]" do
        it "if face and dir the same then returns the same instance" do
          {
            {} => free_bond,
            { face: 110, dir: :front } => bond_110
          }.each do |hash, bond|
            Bond[hash].should == bond
          end
        end
      end

      describe "#same?" do
        it { free_bond.same?(bond_110).should be_true }
        it { bond_110.same?(free_bond).should be_true }
      end
    end

  end
end
