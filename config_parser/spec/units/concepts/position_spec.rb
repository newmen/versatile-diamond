require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Position do
      describe "#self.[]" do
        it "if face and dir the same then returns the same instance" do
          Position[face: 100, dir: :front].should == position_100_front
        end

        it "if no has face or dir then raise error" do
          expect { Position[face: nil, dir: nil] }.
            to raise_error Position::Incomplete
        end
      end

      describe "#self.make_from" do
        describe "bond" do
          subject { Position.make_from(bond_100_front) }
          it { should == position_100_front }
        end

        describe "poisition" do
          subject { Position.make_from(position_110_cross) }
          it { should == position_110_cross }
        end
      end

      describe "#face" do
        it { position_100_front.face.should == 100 }
        it { position_100_cross.face.should == 100 }
      end

      describe "#dir" do
        it { position_100_front.dir.should == :front }
        it { position_100_cross.dir.should == :cross }
      end

      describe "#same?" do
        it { position_100_front.same?(position_100_cross).should be_false }
        it { position_100_front.same?(bond_110_front).should be_false }
        it { position_100_front.same?(bond_100_front).should be_true }
      end
    end

  end
end
