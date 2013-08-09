require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Position do
      let(:position_front) { Position[face: 100, dir: :front] }

      describe "#self.[]" do
        it "if face and dir the same then returns the same instance" do
          Position[face: 100, dir: :front].should == position_front
        end

        it "if no has face or dir then raise error" do
          -> { Position[face: nil, dir: nil] }.
            should raise_error Position::IncompleteError
        end
      end

      describe "#same?" do
        let(:position_cross) { Position[face: 100, dir: :cross] }
        let(:bond_front) { Bond[face: 100, dir: :front] }

        it { position_front.same?(position_cross).should be_false }
        it { position_front.same?(bond_front).should be_true }
      end
    end

  end
end
