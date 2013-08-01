require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SpecificSpec do
      let(:h) { Atom.new('H', 1) }
      let(:c) { Atom.new('C', 4) }
      let(:c2) { Atom.new('C', 4) }
      let(:undir_bond) { Bond[face: nil, dir: nil] }

      let(:hydrogen_base) { Spec.new(:hydrogen, h: h) }
      let(:hydrogen) { SpecificSpec.new(hydrogen_base) }
      let(:hydrogen_ion) do
        activated_h = SpecificAtom.new(h)
        activated_h.active!
        SpecificSpec.new(hydrogen_base, h: activated_h)
      end

      let(:methane_base) { Spec.new(:methane, c: c) }
      let(:methane) { SpecificSpec.new(methane_base) }
      let(:methyl) do
        activated_c = SpecificAtom.new(c)
        activated_c.active!
        SpecificSpec.new(methane_base, c: activated_c)
      end

      let(:bridge_base) do
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
      let(:bridge) { SpecificSpec.new(bridge_base) }
      let(:extra_activated_bridge) do
        activated_c = SpecificAtom.new(c)
        activated_c.active!
        activated_c.active!
        SpecificSpec.new(bridge_base, ct: activated_c)
      end

      describe "#external_bonds" do
        it { hydrogen.external_bonds.should == 0 }
        it { hydrogen_ion.external_bonds.should == 0 }
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
    end

  end
end
