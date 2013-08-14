require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SpecificSpec do
      describe "#dup" do
        it { methyl.dup.should_not == methyl }
        it { methyl.dup.spec.should == methyl.spec }
        it { methyl.dup.external_bonds.should == 3 }
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
        it { bridge.changed_atoms(activated_bridge).first.should == cd }
        it { activated_bridge.changed_atoms(bridge).first.
          should == activated_cd }
        it { activated_bridge.changed_atoms(extra_activated_bridge).first.
          should == activated_cd }
        it { extra_activated_bridge.changed_atoms(activated_bridge).first.
          actives.should == 2 }
      end
    end

  end
end
