require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Spec do
      describe "self#good_for_reduce?" do
        it { described_class.good_for_reduce?([:cl]).should be_true }
        it { described_class.good_for_reduce?([:_cl]).should be_false }
      end

      describe "#simple?" do
        it { Spec.new(:not_set).simple?.should be_nil }

        it { hydrogen_base.simple?.should be_true }
        it { methane_base.simple?.should_not be_true }
        it { ethylene_base.simple?.should_not be_true }
        it { bridge_base.simple?.should_not be_true }
      end

      describe "#atom" do
        it { methane_base.atom(:w).should be_nil }
        it { methane_base.atom(:c).should == c }
      end

      describe "#keyname" do
        it { methane_base.keyname(c).should == :c }
        it { bridge_base.keyname(cd).should == :ct }
      end

      describe "#describe_atom" do
        it "atom stores to spec" do
          spec = Spec.new(:some)
          spec.describe_atom(:c, c)
          spec.atom(:c).should == c
        end
      end

      describe "#rename_atom" do
        describe "old atom keyname changes to new keyname" do
          before(:each) { methane_base.rename_atom(:c, :new_c) }
          it { methane_base.atom(:new_c).should == c }
        end

        describe "if keyname already exist before renaming it" do
          before(:each) { ethylene_base.rename_atom(:c1, :c2) }
          it { ethylene_base.atom(:c1).should be_nil }
          it { ethylene_base.atom(:c2).should == c1 }
          it { ethylene_base.size.should == 2 }
        end
      end

      describe "#links" do
        it { methane_base.links.should == { c => [] } }
        it { ethylene_base.links.should == {
          c1 => [[c2, free_bond], [c2, free_bond]],
          c2 => [[c1, free_bond], [c1, free_bond]] } }
      end

      describe "#adsorb" do
        describe "methane adsorbs each atom and links of ethylene" do
          subject { methane_base }
          before(:each) { subject.adsorb(ethylene_base) }
          it { subject.external_bonds_for(subject.atom(:c)).should == 4 }
          it { subject.external_bonds_for(subject.atom(:c1)).should == 2 }
          it { subject.external_bonds_for(subject.atom(:c2)).should == 2 }
        end
      end

      describe "#external_bonds_for" do
        describe "methane" do
          subject { methane_base }
          it { subject.external_bonds_for(subject.atom(:c)).should == 4 }
        end

        describe "ethylene" do
          subject { ethylene_base }
          it { subject.external_bonds_for(subject.atom(:c1)).should == 2 }
          it { subject.external_bonds_for(subject.atom(:c2)).should == 2 }
        end

        describe "bridge" do
          subject { bridge_base }
          it { subject.external_bonds_for(subject.atom(:ct)).should == 2 }
          it { subject.external_bonds_for(subject.atom(:cl)).should == 1 }
          it { subject.external_bonds_for(subject.atom(:cr)).should == 1 }
        end

        describe "chloride_bridge" do
          subject { chloride_bridge_base }
          it { subject.external_bonds_for(subject.atom(:ct)).should == 1 }
        end

        describe "methyl on bridge" do
          subject { methyl_on_bridge_base }
          it { subject.external_bonds_for(subject.atom(:cm)).should == 3 }
          it { subject.external_bonds_for(subject.atom(:cb)).should == 1 }
          it { subject.external_bonds_for(subject.atom(:cl)).should == 1 }
          it { subject.external_bonds_for(subject.atom(:cr)).should == 1 }
        end

        describe "methyl on dimer" do
          subject { methyl_on_dimer_base }
          it { subject.external_bonds_for(subject.atom(:cm)).should == 3 }
          it { subject.external_bonds_for(subject.atom(:cr)).should == 0 }
          it { subject.external_bonds_for(subject.atom(:cl)).should == 1 }
        end
      end

      describe "#external_bonds" do
        it { hydrogen_base.external_bonds.should == 2 }
        it { methane_base.external_bonds.should == 4 }
        it { ethylene_base.external_bonds.should == 4 }
        it { bridge_base.external_bonds.should == 4 }
      end

      describe "#extendable?" do
        it { methane_base.extendable?.should be_false }
        it { ethylene_base.extendable?.should be_false }
        it { bridge_base.extendable?.should be_true }
      end

      describe "#extend_by_references" do
        it { extended_bridge_base.external_bonds.should == 8 }
        it { methyl_on_extended_bridge_base.external_bonds.should == 10 }
        it { methyl_on_dimer_base.extend_by_references.external_bonds.
          should == 16 } # if take into account the crystal lattice then value
          # should be 10
      end

      describe "#links_with_replace_by" do
        let(:links) { ethylene_base.links_with_replace_by(c2: o) }

        it { links.include?(o).should be_true }
        it { links[c1].select { |a, _| a == o }.size.should == 2 }
      end

      describe "#parent" do
        it { bridge_base.parent.should be_nil } # by default
      end

      describe "#organize_dependencies!" do
        before { methyl_on_bridge_base.organize_dependencies!([bridge_base]) }
        it { methyl_on_bridge_base.parent.should == bridge_base }
      end

      describe "#theres" do
        it { dimer_base.theres.should be_empty }
      end

      describe "#store_there" do
        before { dimer_base.store_there(on_end) }
        it { dimer_base.theres.should == [on_end] }
      end

      describe "#childs" do
        it { dimer_base.childs.should be_empty }
      end

      describe "#store_child" do
        before { dimer_base.store_child(methyl_on_dimer_base) }
        it { dimer_base.childs.should == [methyl_on_dimer_base] }
      end

      describe "#append_childs" do
        before { dimer_base.append_childs([activated_dimer]) }
        it { dimer_base.childs.should == [activated_dimer] }
      end

      describe "#remove_child" do
        before do
          dimer_base.store_child(dimer)
          dimer_base.remove_child(dimer)
        end
        it { dimer_base.childs.should be_empty }
      end

      describe "#size" do
        it { hydrogen_base.size.should == 1 }
        it { methane_base.size.should == 1 }
        it { ethylene_base.size.should == 2 }
        it { bridge_base.size.should == 3 }
        it { methyl_on_bridge_base.size.should == 4 }
        it { methyl_on_extended_bridge_base.size.should == 8 }
        it { high_bridge_base.size.should == 4 }
        it { dimer_base.size.should == 6 }
        it { extended_dimer_base.size.should == 14 } # if take into account the
        # crystal lattice then value should be 12
        it { methyl_on_dimer_base.size.should == 7 }
      end

      it_behaves_like "visitable" do
        subject { methane_base }
      end
    end

  end
end