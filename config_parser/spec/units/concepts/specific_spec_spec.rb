require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SpecificSpec do
      let(:h) { Atom.new('H', 1) }
      let(:c) { Atom.new('C', 4) }
      let(:c2) { Atom.new('C', 4) }
      let(:undir_bond) { Bond[face: nil, dir: nil] }

      let(:hydrogen_base) { GasSpec.new(:hydrogen, h: h) }
      let(:hydrogen) { SpecificSpec.new(hydrogen_base) }
      let(:hydrogen_ion) do
        activated_h = SpecificAtom.new(h)
        activated_h.active!
        SpecificSpec.new(hydrogen_base, h: activated_h)
      end

      let(:methane_base) { GasSpec.new(:methane, c: c) }
      let(:methane) { SpecificSpec.new(methane_base) }
      let(:methyl) do
        activated_c = SpecificAtom.new(c)
        activated_c.active!
        SpecificSpec.new(methane_base, c: activated_c)
      end

      let(:bridge_base) do
        c.lattice = Lattice.new(:d, 'Diamond')
        spec = SurfaceSpec.new(:bridge, ct: c)
        cl, cr = AtomReference.new(spec, :ct), AtomReference.new(spec, :ct)
        spec.describe_atom(:cl, cl)
        spec.describe_atom(:cr, cr)
        bond110 = Bond[face: 110, dir: :front]
        spec.link(c, cl, bond110)
        spec.link(c, cr, bond110)
        spec
      end
      let(:bridge) { SpecificSpec.new(bridge_base) }
      let(:extra_activated_bridge) do
        activated_c = SpecificAtom.new(c)
        activated_c.active!
        activated_c.active!
        SpecificSpec.new(bridge_base, ct: activated_c)
      end

      describe "#is_gas?" do
        it { hydrogen.is_gas?.should be_true }
        it { hydrogen_ion.is_gas?.should be_true }
        it { methane.is_gas?.should be_true }
        it { methyl.is_gas?.should be_true }
        it { bridge.is_gas?.should be_false }
        it { extra_activated_bridge.is_gas?.should be_false }
      end

      describe "#simple?" do
        it { hydrogen.simple?.should be_true }
        it { hydrogen_ion.simple?.should be_true }
        it { methane.simple?.should be_false }
        it { methyl.simple?.should be_false }
        it { bridge.simple?.should be_false }
        it { extra_activated_bridge.simple?.should be_false }
      end

      describe "#external_bonds" do
        it { hydrogen.external_bonds.should == 2 }
        it { hydrogen_ion.external_bonds.should == 1 }
        it { methane.external_bonds.should == 4 }
        it { methyl.external_bonds.should == 3 }
        it { bridge.external_bonds.should == 4 }
        it { extra_activated_bridge.external_bonds.should == 2 }
      end

      describe "#extendable?" do
        it { methane.extendable?.should be_false }
        it { methyl.extendable?.should be_false }
        it { bridge.extendable?.should be_true }
        it { extra_activated_bridge.extendable?.should be_true }
      end

      describe "#external_bonds_after_extend" do
        it { bridge.external_bonds_after_extend.should == 8 }
        it { extra_activated_bridge.external_bonds_after_extend.should == 6 }
      end

      describe "#extend!" do
        it "extends before check" do
          bridge.extend!
          bridge.external_bonds.should == 8
        end
      end

      describe "#changed_atoms" do
        let(:activated_c) do
          a = SpecificAtom.new(c)
          a.active!; a
        end
        let(:activated_bridge) do
          SpecificSpec.new(bridge_base, ct: activated_c)
        end

        it { bridge.changed_atoms(activated_bridge).first.should == c }
        it { activated_bridge.changed_atoms(bridge).first.
          should == activated_c }
        it { activated_bridge.changed_atoms(extra_activated_bridge).first.
          should == activated_c }
        it { extra_activated_bridge.changed_atoms(activated_bridge).first.
          actives.should == 2 }
      end
    end

  end
end
