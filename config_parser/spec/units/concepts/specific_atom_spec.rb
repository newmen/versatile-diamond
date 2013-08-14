require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SpecificAtom, type: :latticed_ref_atom do
      let(:specific_atom) { SpecificAtom.new(n) }

      describe "#dup" do
        it { specific_atom.dup.should_not == specific_atom }
        it { activated_c.dup.actives.should == 1 }
        it { activated_cd.dup.lattice.should == diamond }
      end

      describe "#actives" do
        it { specific_atom.actives.should == 0 }

        it { activated_h.actives.should == 1 }
        it { activated_c.actives.should == 1 }
        it { activated_cd.actives.should == 1 }
        it { extra_activated_cd.actives.should == 2 }
      end

      describe "#same?" do
        it { specific_atom.same?(n).should be_false }
        it { n.same?(specific_atom).should be_false }

        describe "same class instance" do
          let(:other) { SpecificAtom.new(n.dup) }

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
        let(:target) { n }
        let(:reference) { specific_atom }
      end

    end

  end
end
