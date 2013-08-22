require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SpecificSpec do
      describe "#dup" do
        it { methyl.dup.should_not == methyl }
        it { methyl.dup.spec.should == methyl.spec }
        it { methyl.dup.external_bonds.should == 3 }
      end

      describe "#full_name" do
        it { methane.full_name.should == 'methane' }
        it { methyl.full_name.should == 'methane(c: *)' }

        it { bridge.full_name.should == 'bridge' }
        it { activated_bridge.full_name.should == 'bridge(ct: *)' }
        it { extra_activated_bridge.full_name.should == 'bridge(ct: **)' }
        it { activated_incoherent_bridge.full_name.
          should == 'bridge(ct: *, ct: i)' }

        it { methyl_on_bridge.full_name.should == 'methyl_on_bridge' }
        it { activated_methyl_on_bridge.full_name.
          should == 'methyl_on_bridge(cm: *)' }
        it { unfixed_methyl_on_bridge.full_name.
          should == 'methyl_on_bridge(cm: u)' }
        it { methyl_on_activated_bridge.full_name.
          should == 'methyl_on_bridge(cb: *)' }
      end

      describe "#atom" do
        it { methyl.atom(:c).should == activated_c }
        it { bridge.atom(:ct).should == cd }
        it { activated_bridge.atom(:ct).should == activated_cd }
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

      describe "#incoherent!" do
        before { activated_bridge.incoherent!(:ct) }
        it { activated_cd.incoherent?.should be_true }
      end

      describe "#unfixed!" do
        before { activated_methyl_on_bridge.unfixed!(:cm) }
        it { activated_c.unfixed?.should be_true }
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

      describe "#look_around!" do
        before(:each) { methyl_on_bridge.look_around!(md_atom_map) }
        it { methyl_on_bridge.atom(:cm).should be_a(SpecificAtom) }
        it { methyl_on_bridge.atom(:cm).unfixed?.should be_true }
        it { methyl_on_bridge.atom(:cm).incoherent?.should be_true }
      end

      describe "#dependet_from" do
        # default state of dependent from variable
        it { bridge.dependent_from.should be_nil }
        it { activated_bridge.dependent_from.should be_nil }
      end

      describe "#organize_dependencies" do
        shared_examples_for "organize and check" do
          before { target.organize_dependencies(similars) }
          it { target.dependent_from.should == parent }
        end

        describe "bridge" do
          let(:similars) { [bridge, activated_bridge,
            activated_incoherent_bridge, extra_activated_bridge] }

          it_behaves_like "organize and check" do
            let(:target) { bridge }
            let(:parent) { nil }
          end

          it_behaves_like "organize and check" do
            let(:target) { activated_bridge }
            let(:parent) { bridge }
          end

          it_behaves_like "organize and check" do
            let(:target) { activated_incoherent_bridge }
            let(:parent) { activated_bridge }
          end

          it_behaves_like "organize and check" do
            let(:target) { extra_activated_bridge }
            let(:parent) { activated_bridge }
          end
        end

        describe "methyl on bridge" do
          let(:similars) { [methyl_on_bridge, activated_methyl_on_bridge,
            methyl_on_activated_bridge, methyl_on_incoherent_bridge,
            unfixed_methyl_on_bridge, activated_methyl_on_incoherent_bridge,
            unfixed_activated_methyl_on_bridge] }

          it_behaves_like "organize and check" do
            let(:target) { methyl_on_bridge }
            let(:parent) { nil }
          end

          it_behaves_like "organize and check" do
            let(:target) { activated_methyl_on_bridge }
            let(:parent) { methyl_on_bridge }
          end

          it_behaves_like "organize and check" do
            let(:target) { methyl_on_activated_bridge }
            let(:parent) { methyl_on_bridge }
          end

          it_behaves_like "organize and check" do
            let(:target) { methyl_on_incoherent_bridge }
            let(:parent) { methyl_on_bridge }
          end

          it_behaves_like "organize and check" do
            let(:target) { unfixed_methyl_on_bridge }
            let(:parent) { methyl_on_bridge }
          end

          it_behaves_like "organize and check" do
            let(:target) { activated_methyl_on_incoherent_bridge }
            let(:parent) { activated_methyl_on_bridge }
          end

          it_behaves_like "organize and check" do
            let(:target) { unfixed_activated_methyl_on_bridge }
            let(:parent) { activated_methyl_on_bridge }
          end
        end

        describe "dimer" do
          let(:similars) { [dimer, activated_dimer] }

          it_behaves_like "organize and check" do
            let(:target) { dimer }
            let(:parent) { nil }
          end

          it_behaves_like "organize and check" do
            let(:target) { activated_dimer }
            let(:parent) { dimer }
          end
        end
      end
    end

  end
end
