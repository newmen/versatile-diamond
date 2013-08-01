require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Spec do
      let(:h) { Atom.new('H', 1) }
      let(:c) { Atom.new('C', 4) }
      let(:c2) { Atom.new('C', 4) }
      let(:undir_bond) { Bond[face: nil, dir: nil] }

      let(:hydrogen) { Spec.new(:hydrogen, h: h) }
      let(:methane) { Spec.new(:methane, c: c) }

      let(:ethylene) do
        spec = Spec.new(:ethylene, c1: c, c2: c2)
        spec.link(c, c2, undir_bond)
        spec.link(c, c2, undir_bond)
        spec
      end

      let(:bridge) do
        c.lattice = Lattice.new(:d, 'Diamond')
        spec = Spec.new(:bridge, ct: c)
        cl, cr = AtomReference.new(spec, :ct), AtomReference.new(spec, :ct)
        spec.describe_atom(:cl, cl)
        spec.describe_atom(:cr, cr)
        bond110 = Bond[face: 110, dir: :front]
        spec.link(c, cl, bond110)
        spec.link(c, cr, bond110)
        spec
      end

      describe "#simple?" do
        it { Spec.new(:not_set).simple?.should be_nil }

        it { hydrogen.simple?.should be_true }
        it { methane.simple?.should_not be_true }
        it { ethylene.simple?.should_not be_true }
        it { bridge.simple?.should_not be_true }
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
        it { ethylene.external_bonds_for(ethylene.atom(:c1)).should == 2 }
        it { ethylene.external_bonds_for(ethylene.atom(:c2)).should == 2 }
      end

      describe "#external_bonds" do
        it { hydrogen.external_bonds.should == 0 }
        it { methane.external_bonds.should == 4 }
        it { ethylene.external_bonds.should == 4 }
        it { bridge.external_bonds.should == 4 }
      end

      describe "#extendable?" do
        it { methane.extendable?.should be_false }
        it { ethylene.extendable?.should be_false }
        it { bridge.extendable?.should be_true }
      end

      describe "#extend_by_references" do
        it { bridge.extend_by_references.external_bonds.should == 8 }
      end

      describe "#links_with_replace_by" do
        it "replacing to number" do
          links = ethylene.links_with_replace_by(c2: 2)
          links.include?(2).should be_true
          links[c].select { |a, _| a == 2 }.size.should == 2
        end
      end
    end

  end
end
