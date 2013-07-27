require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Spec do
      let(:h) { Atom.new('H', 1) }
      let(:c) { Atom.new('C', 4) }
      let(:c2) { Atom.new('C', 4) }
      let(:undir_bond) { Bond[face: nil, dir: nil] }

      let(:methane) do
        spec = Spec.new(:methane, c: c)
        spec
      end

      describe "#simple?" do
        it { Spec.new(:not_set).simple?.should be_nil }

        let(:hydrogen) do
          spec = Spec.new(:hydrogen, h: h)
          spec
        end

        it { hydrogen.simple?.should be_true }
        it { methane.simple?.should_not be_true }
      end

      describe "#atom" do
        it { methane.atom(:w).should be_nil }
        it { methane.atom(:c).should == c }
      end

      describe "#duplicate_atoms_with_keynames" do
        it { methane.duplicate_atoms_with_keynames.should_not == { c: c } }
      end

      describe "#describe_atom" do
        it "atom stores to spec" do
          spec = Spec.new(:some)
          spec.describe_atom(:c, c)
          spec.atom(:c).should == c
        end
      end

      describe "#rename_atom" do
        it "old atom keyname changes to new keyname" do
          methane.rename_atom(:c, :new_c)
          methane.atom(:new_c).should == c
        end
      end

      describe "#link" do
        let(:position) { Position[face: 100, dir: :front] }
        let(:two_c_atoms) do
          spec = Spec.new(:two_c_atoms, c1: c, c2: c2)
          spec.link(c, c2, undir_bond)
          spec.link(c, c2, undir_bond)
          spec.link(c, c2, undir_bond)
          spec.link(c, c2, undir_bond)
          spec
        end

        it "valid bonds number" do
          -> { two_c_atoms.link(c, c2, position) }.
            should_not raise_error Atom::IncorrectValence
        end

        it "wrong bonds number" do
          -> { two_c_atoms.link(c, c2, undir_bond) }.
            should raise_error Atom::IncorrectValence
        end
      end

      describe "#adsorb_links" do
        let(:ethane) do
          spec = Spec.new(:ethane, c1: c, c2: c2)
          spec.link(c, c2, undir_bond)
          spec
        end

        it "methane adsorbs each atom and links of ethane" do
          duplicates = ethane.duplicate_atoms_with_keynames
          duplicates.each do |keyname, atom_dup|
            methane.describe_atom(keyname, atom_dup)
          end
          methane.adsorb_links(ethane, duplicates)
          methane.external_bonds_for(duplicates[:c1]).should == 3
        end
      end

      describe "#external_bonds_for" do
        let(:ethylene) do
          spec = Spec.new(:ethylene, c1: c, c2: c2)
          spec.link(c, c2, undir_bond)
          spec.link(c, c2, undir_bond)
          spec
        end

        it { ethylene.external_bonds_for(ethylene.atom(:c1)).should == 2 }
        it { ethylene.external_bonds_for(ethylene.atom(:c2)).should == 2 }
      end
    end

  end
end
