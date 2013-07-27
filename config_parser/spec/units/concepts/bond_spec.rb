require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Bond do
      describe "#self.[]" do
        it "if face and dir the same then returns the same instance" do
          {
            {} => Bond[face: nil, dir: nil],
            { face: 100, dir: :front } => Bond[face: 100, dir: :front]
          }.each do |hash, bond|
            Bond[hash].should == bond
          end
        end
      end
    end

  end
end
