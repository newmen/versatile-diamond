require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Position do
      describe "#self.[]" do
        it "if face and dir the same then returns the same instance" do
          position = Position[face: 100, dir: :front]
          Position[face: 100, dir: :front].should == position
        end

        it "if no has face or dir then raise error" do
          -> { Position[face: nil, dir: nil] }.
            should raise_error Position::IncompleteError
        end
      end
    end

  end
end
