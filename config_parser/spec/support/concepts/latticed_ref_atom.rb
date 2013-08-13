module VersatileDiamond
  module Concepts
    module Support

      module LatticedRefAtom
        shared_examples_for "#lattice" do
          describe "#lattice" do
            it { reference.lattice.should be_nil }

            it "reference to latticed atom" do
              target.lattice = diamond
              reference.lattice.should == diamond
            end

            describe "#lattice=" do
              it "don't change original atom" do
                reference.lattice = diamond
                target.lattice.should be_nil
              end
            end
          end
        end
      end


    end
  end
end
