require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SpecificSpec do
      describe "#dup" do
        it { methyl.dup.should_not == methyl }
        it { methyl.dup.spec.should == methyl.spec }
        it { methyl.dup.external_bonds.should == 3 }
      end

      describe "#spec" do
        it { methyl.spec.should == methane_base }
        it { bridge.spec.should == bridge_base }
        it { dimer.spec.should == dimer_base }
      end

      describe "#update_base_spec" do
        before(:each) { high_bridge.update_base_spec(bridge_base) }
        it { high_bridge.spec.should == bridge_base }
        it { high_bridge.name.should == :high_bridge }
      end

      describe "#position_between" do
        it { activated_dimer.position_between(
            activated_dimer.atom(:cr), activated_dimer.atom(:cl)).
          should == position_100_front }

        it { activated_dimer.position_between(
            activated_dimer.atom(:cl), activated_dimer.atom(:cr)).
          should == position_100_front }

        it { activated_methyl_on_incoherent_bridge.position_between(
            activated_methyl_on_incoherent_bridge.atom(:cm),
            activated_methyl_on_incoherent_bridge.atom(:cb)).should be_nil }

        it { activated_methyl_on_incoherent_bridge.position_between(
            activated_methyl_on_incoherent_bridge.atom(:cb),
            activated_methyl_on_incoherent_bridge.atom(:cm)).should be_nil }
      end

      describe "#name" do
        it { bridge.name.should == :bridge }
      end

      describe "#full_name" do
        it { methane.full_name.should == 'methane()' }
        it { methyl.full_name.should == 'methane(c: *)' }

        it { bridge.full_name.should == 'bridge()' }
        it { activated_bridge.full_name.should == 'bridge(ct: *)' }
        it { extra_activated_bridge.full_name.should == 'bridge(ct: **)' }
        it { hydrogenated_bridge.full_name.should == 'bridge(ct: H)' }
        it { activated_hydrogenated_bridge.full_name.
          should == 'bridge(ct: *, ct: H)' }
        it { activated_incoherent_bridge.full_name.
          should == 'bridge(ct: *, ct: i)' }

        it { methyl_on_bridge.full_name.should == 'methyl_on_bridge()' }
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

      describe "#keyname" do
        it { methyl.keyname(activated_c).should == :c }
        it { bridge.keyname(cd).should == :ct }
        it { activated_dimer.keyname(activated_cd).should == :cr }
        it { activated_dimer.keyname(activated_dimer.atom(:cl)).should == :cl }
      end

      describe "#describe_atom" do
        before { bridge.describe_atom(:ct, activated_cd) }
        it { bridge.atom(:ct).should == activated_cd }
        it { bridge.keyname(activated_cd).should == :ct }
      end

      describe "#links" do
        it { methyl.links.should == { activated_c => [] } }
        it { vinyl.links.should == {
          activated_c => [[c2, free_bond], [c2, free_bond]],
          c2 => [[activated_c, free_bond], [activated_c, free_bond]] } }
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

      describe "#external_bonds_for" do
        it { methane.external_bonds_for(c).should == 4 }
        it { methyl.external_bonds_for(activated_c).should == 3 }
        it { bridge.external_bonds_for(cd).should == 2 }
        it { activated_bridge.external_bonds_for(activated_cd).should == 1 }
        it { extra_activated_bridge.external_bonds_for(extra_activated_cd).
          should == 0 }
        it { chloride_bridge.external_bonds_for(chloride_bridge.atom(:ct)).
          should == 1 }
        it { methyl_on_bridge.external_bonds_for(c).should == 3 }
        it { activated_methyl_on_bridge.external_bonds_for(activated_c).
          should == 2 }
        it { methyl_on_activated_bridge.external_bonds_for(c).should == 3 }
        it { methyl_on_activated_bridge.external_bonds_for(activated_cd).
          should == 0 }
        it { methyl_on_dimer.external_bonds_for(methyl_on_dimer.atom(:cr)).
          should == 0 }
      end

      describe "#external_bonds" do
        it { hydrogen.external_bonds.should == 2 }
        it { hydrogen_ion.external_bonds.should == 1 }
        it { methane.external_bonds.should == 4 }
        it { methyl.external_bonds.should == 3 }
        it { bridge.external_bonds.should == 4 }
        it { extra_activated_bridge.external_bonds.should == 2 }
        it { chloride_bridge.external_bonds.should == 3 }
      end

      describe "#extended?" do
        it { bridge.extended?.should be_false }
        it { dimer.extended?.should be_false }

        it { activated_methyl_on_extended_bridge.extended?.should be_true }
        it { right_activated_extended_bridge.extended?.should be_true }
        it { extended_dimer.extended?.should be_true }
      end

      describe "#reduced" do
        it { bridge.reduced.should be_nil }
        it { dimer.reduced.should be_nil }

        it { activated_methyl_on_extended_bridge.reduced.
          should == activated_methyl_on_bridge }
        it { right_activated_extended_bridge.reduced.
          should == right_activated_bridge }
        it { extended_dimer.reduced.should == dimer }
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

      describe "#extended" do
        it { bridge.extended.external_bonds.should == 8 }
        it { activated_bridge.extended.external_bonds.should == 7 }

        describe "exchange specific atom" do
          subject { SpecificSpec.new(bridge_base, cr: activated_cd).extended }
          it { subject.atom(:cr).valence.should == 3 }
        end
      end

      describe "#specific?" do
        it { bridge.specific?.should be_false }
        it { dimer.specific?.should be_false }
        it { high_bridge.specific?.should be_false }

        it { right_activated_bridge.specific?.should be_true }
        it { activated_dimer.specific?.should be_true }
      end

      describe "#could_be_reduced?" do
        it { activated_methyl_on_extended_bridge.could_be_reduced?.should be_true }
        it { right_activated_extended_bridge.could_be_reduced?.should be_true }
        it { extended_dimer.could_be_reduced?.should be_true }
      end

      describe "#parent" do
        # default state of dependent from variable
        it { bridge.parent.should be_nil }
        it { activated_bridge.parent.should be_nil }
      end

      describe "#organize_dependencies!" do
        shared_examples_for "organize and check" do
          before { target.organize_dependencies!(similars) }
          it { target.parent.should == parent }
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
            unfixed_activated_methyl_on_incoherent_bridge] }

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
            let(:target) { unfixed_activated_methyl_on_incoherent_bridge }
            let(:parent) { activated_methyl_on_incoherent_bridge }
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

      describe "#childs" do
        it { dimer.childs.should be_empty }
      end

      describe "#store_child" do
        before { dimer.store_child(methyl_on_dimer) }
        it { dimer.childs.should == [methyl_on_dimer] }
      end

      describe "#reactions" do
        it { dimer.reactions.should be_empty }
      end

      describe "#store_reaction" do
        before { dimer.store_reaction(dimer_formation) }
        it { dimer.reactions.should == [dimer_formation] }
      end

      describe "#theres" do
        it { dimer.theres.should be_empty }
      end

      describe "#store_reaction" do
        before { dimer.store_there(on_end) }
        it { dimer.theres.should == [on_end] }
      end

      describe "#same?" do
        it { methyl.same?(methyl.dup).should be_true }
        it { bridge.same?(bridge.dup).should be_true }

        it { methyl.same?(active_bond).should be_false }
        it { methyl.same?(adsorbed_h).should be_false }

        it { methyl.same?(bridge).should be_false }
        it { bridge.same?(activated_bridge).should be_false }
        it { activated_bridge.same?(activated_incoherent_bridge).
          should be_false }
        it { activated_bridge.same?(extra_activated_bridge).
          should be_false }
        it { extra_activated_bridge.same?(activated_incoherent_bridge).
          should be_false }
      end

      describe "#has_termination_atom?" do
        it { bridge.has_termination_atom?(cd, h).should be_true }
        it { activated_bridge.has_termination_atom?(activated_cd, h).
          should be_true }
        it { extra_activated_bridge.has_termination_atom?(
          extra_activated_cd, h). should be_false }

        it { chloride_bridge.has_termination_atom?(
          chloride_bridge.atom(:ct), h). should be_true }
        it { chloride_bridge.has_termination_atom?(
          chloride_bridge.atom(:ct), cl). should be_true }
      end

      describe "#size" do
        it { methane.size.should == 0 }
        it { methyl.size.should == 0 }
        it { bridge.size.should == 3 }
        it { hydrogenated_bridge.size.should == 3.75 }
        it { activated_hydrogenated_bridge.size.should == 4.63 }
        it { extra_activated_bridge.size.should == 4.76 }
        it { activated_methyl_on_incoherent_bridge.size.should == 5.21 }
      end

      it_behaves_like "visitable" do
        subject { methyl }
      end
    end

  end
end
