module VersatileDiamond
  module Support
    module Concepts

      module LatticedRefAtom
        shared_examples_for "#lattice" do
          describe "#lattice" do
            let(:lattice) do
              VersatileDiamond::Concepts::Lattice.new(:d, cpp_class: 'Diamond')
            end

            it { reference.lattice.should be_nil }

            it "reference to latticed atom" do
              target.lattice = lattice
              reference.lattice.should == lattice
            end

            describe "#lattice=" do
              it "don't change original atom" do
                reference.lattice = lattice
                target.lattice.should be_nil
              end
            end
          end
        end
      end


    end
  end
end
