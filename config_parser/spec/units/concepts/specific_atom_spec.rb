require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SpecificAtom, type: :latticed_ref_atom do
      let(:atom) { Atom.new('N', 3) }
      let(:specific_atom) { SpecificAtom.new(atom) }

      describe "#actives" do
        it { specific_atom.actives.should == 0 }

        it "value changes when atom activated" do
          specific_atom.active!
          specific_atom.actives.should == 1
        end
      end

      describe "#same?" do
        it { specific_atom.same?(atom).should be_false }
        it { atom.same?(specific_atom).should be_false }

        describe "same class instance" do
          let(:other) { SpecificAtom.new(atom.dup) }

          it "both atoms is activated" do
            specific_atom.active!
            other.active!
            specific_atom.same?(other).should be_true
          end

          it "just one atom is activated" do
            other.active!
            specific_atom.same?(other).should be_false
          end
        end
      end

      it_behaves_like "#lattice" do
        let(:target) { atom }
        let(:reference) { specific_atom }
      end

    end

  end
end
