require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SpecificSpec do
      describe '#dup' do
        it { expect(methyl.dup).not_to eq(methyl) }
        it { expect(methyl.dup.spec).to eq(methyl.spec) }
        it { expect(methyl.dup.external_bonds).to eq(3) }
      end

      describe '#spec' do
        it { expect(methyl.spec).to eq(methane_base) }
        it { expect(bridge.spec).to eq(bridge_base) }
        it { expect(dimer.spec).to eq(dimer_base) }
      end

      describe '#specific_atoms' do
        it { expect(bridge.specific_atoms).to be_empty }
        it { expect(activated_dimer.specific_atoms).to eq({cr: activated_cd}) }
      end

      describe '#update_base_spec' do
        before(:each) { high_bridge.update_base_spec(bridge_base) }
        it { expect(high_bridge.spec).to eq(bridge_base) }
        it { expect(high_bridge.name).to eq(:high_bridge) }
      end

      describe '#position_between' do
        it { expect(activated_dimer.position_between(
            activated_dimer.atom(:cr), activated_dimer.atom(:cl))).
          to eq(position_100_front) }

        it { expect(activated_dimer.position_between(
            activated_dimer.atom(:cl), activated_dimer.atom(:cr))).
          to eq(position_100_front) }

        it { expect(activated_methyl_on_incoherent_bridge.position_between(
            activated_methyl_on_incoherent_bridge.atom(:cm),
            activated_methyl_on_incoherent_bridge.atom(:cb))).to be_nil }

        it { expect(activated_methyl_on_incoherent_bridge.position_between(
            activated_methyl_on_incoherent_bridge.atom(:cb),
            activated_methyl_on_incoherent_bridge.atom(:cm))).to be_nil }
      end

      describe '#name' do
        it { expect(bridge.name).to eq(:bridge) }
      end

      describe '#full_name' do
        it { expect(methane.full_name).to eq(:'methane()') }
        it { expect(methyl.full_name).to eq(:'methane(c: *)') }

        it { expect(bridge.full_name).to eq(:'bridge()') }
        it { expect(activated_bridge.full_name).to eq(:'bridge(ct: *)') }
        it { expect(extra_activated_bridge.full_name).to eq(:'bridge(ct: **)') }
        it { expect(hydrogenated_bridge.full_name).to eq(:'bridge(ct: H)') }
        it { expect(activated_hydrogenated_bridge.full_name).
          to eq(:'bridge(ct: *, ct: H)') }
        it { expect(activated_incoherent_bridge.full_name).
          to eq(:'bridge(ct: *, ct: i)') }

        it { expect(methyl_on_bridge.full_name).to eq(:'methyl_on_bridge()') }
        it { expect(activated_methyl_on_bridge.full_name).
          to eq(:'methyl_on_bridge(cm: *)') }
        it { expect(unfixed_methyl_on_bridge.full_name).
          to eq(:'methyl_on_bridge(cm: u)') }
        it { expect(methyl_on_activated_bridge.full_name).
          to eq(:'methyl_on_bridge(cb: *)') }
      end

      describe '#atom' do
        it { expect(methyl.atom(:c)).to eq(activated_c) }
        it { expect(bridge.atom(:ct)).to eq(cd) }
        it { expect(activated_bridge.atom(:ct)).to eq(activated_cd) }
      end

      describe '#keyname' do
        it { expect(methyl.keyname(activated_c)).to eq(:c) }
        it { expect(bridge.keyname(cd)).to eq(:ct) }
        it { expect(activated_dimer.keyname(activated_cd)).to eq(:cr) }
        it { expect(activated_dimer.keyname(activated_dimer.atom(:cl))).
          to eq(:cl) }
      end

      describe '#describe_atom' do
        before { bridge.describe_atom(:ct, activated_cd) }
        it { expect(bridge.atom(:ct)).to eq(activated_cd) }
        it { expect(bridge.keyname(activated_cd)).to eq(:ct) }
      end

      describe '#links' do
        it { expect(methyl.links).to eq({ activated_c => [] }) }
        it { expect(vinyl.links).to eq({
          activated_c => [[c2, free_bond], [c2, free_bond]],
          c2 => [[activated_c, free_bond], [activated_c, free_bond]] }) }
      end

      describe '#gas?' do
        it { expect(hydrogen.gas?).to be_true }
        it { expect(hydrogen_ion.gas?).to be_true }
        it { expect(methane.gas?).to be_true }
        it { expect(methyl.gas?).to be_true }
        it { expect(bridge.gas?).to be_false }
        it { expect(extra_activated_bridge.gas?).to be_false }
      end

      describe '#simple?' do
        it { expect(hydrogen.simple?).to be_true }
        it { expect(hydrogen_ion.simple?).to be_true }
        it { expect(methane.simple?).to be_false }
        it { expect(methyl.simple?).to be_false }
        it { expect(bridge.simple?).to be_false }
        it { expect(extra_activated_bridge.simple?).to be_false }
      end

      describe '#incoherent!' do
        before { activated_bridge.incoherent!(:ct) }
        it { expect(activated_cd.incoherent?).to be_true }
      end

      describe '#unfixed!' do
        before { activated_methyl_on_bridge.unfixed!(:cm) }
        it { expect(activated_c.unfixed?).to be_true }
      end

      describe '#external_bonds_for' do
        it { expect(methane.external_bonds_for(c)).to eq(4) }
        it { expect(methyl.external_bonds_for(activated_c)).to eq(3) }
        it { expect(bridge.external_bonds_for(cd)).to eq(2) }
        it { expect(activated_bridge.external_bonds_for(activated_cd)).
          to eq(1) }
        it { expect(extra_activated_bridge.external_bonds_for(extra_activated_cd)).
          to eq(0) }
        it { expect(chlorigenated_bridge.external_bonds_for(cd_chloride)).
          to eq(1) }
        it { expect(methyl_on_bridge.external_bonds_for(c)).to eq(3) }
        it { expect(activated_methyl_on_bridge.external_bonds_for(activated_c)).
          to eq(2) }
        it { expect(methyl_on_activated_bridge.external_bonds_for(c)).to eq(3) }
        it { expect(methyl_on_activated_bridge.external_bonds_for(activated_cd)).
          to eq(0) }
        it { expect(methyl_on_dimer.external_bonds_for(methyl_on_dimer.atom(:cr))).
          to eq(0) }
      end

      describe '#external_bonds' do
        it { expect(hydrogen.external_bonds).to eq(2) }
        it { expect(hydrogen_ion.external_bonds).to eq(1) }
        it { expect(methane.external_bonds).to eq(4) }
        it { expect(methyl.external_bonds).to eq(3) }
        it { expect(bridge.external_bonds).to eq(4) }
        it { expect(extra_activated_bridge.external_bonds).to eq(2) }
        it { expect(chlorigenated_bridge.external_bonds).to eq(4) }#3 }
      end

      describe '#extended?' do
        it { expect(bridge.extended?).to be_false }
        it { expect(dimer.extended?).to be_false }

        it { expect(activated_methyl_on_extended_bridge.extended?).to be_true }
        it { expect(right_activated_extended_bridge.extended?).to be_true }
        it { expect(extended_dimer.extended?).to be_true }
      end

      describe '#reduced' do
        it { expect(bridge.reduced).to be_nil }
        it { expect(dimer.reduced).to be_nil }

        it { expect(activated_methyl_on_extended_bridge.reduced).
          to eq(activated_methyl_on_bridge) }
        it { expect(right_activated_extended_bridge.reduced).
          to eq(right_activated_bridge) }
        it { expect(extended_dimer.reduced).to eq(dimer) }
      end

      describe '#extendable?' do
        it { expect(methane.extendable?).to be_false }
        it { expect(methyl.extendable?).to be_false }
        it { expect(bridge.extendable?).to be_true }
        it { expect(extra_activated_bridge.extendable?).to be_true }
      end

      describe '#external_bonds_after_extend' do
        it { expect(bridge.external_bonds_after_extend).to eq(8) }
        it { expect(extra_activated_bridge.external_bonds_after_extend).
          to eq(6) }
      end

      describe '#extended' do
        it { expect(bridge.extended.external_bonds).to eq(8) }
        it { expect(activated_bridge.extended.external_bonds).to eq(7) }

        describe 'exchange specific atom' do
          subject { SpecificSpec.new(bridge_base, cr: activated_cd).extended }
          it { expect(subject.atom(:cr).valence).to eq(3) }
        end
      end

      describe '#could_be_reduced?' do
        it { expect(activated_methyl_on_extended_bridge.could_be_reduced?).to be_true }
        it { expect(right_activated_extended_bridge.could_be_reduced?).to be_true }
        it { expect(extended_dimer.could_be_reduced?).to be_true }
      end

      describe '#same?' do
        it { expect(methyl.same?(methyl.dup)).to be_true }
        it { expect(bridge.same?(bridge.dup)).to be_true }

        it { expect(methyl.same?(active_bond)).to be_false }
        it { expect(methyl.same?(adsorbed_h)).to be_false }

        it { expect(methyl.same?(bridge)).to be_false }
        it { expect(bridge.same?(activated_bridge)).to be_false }
        it { expect(activated_bridge.same?(activated_incoherent_bridge)).
          to be_false }
        it { expect(activated_bridge.same?(extra_activated_bridge)).
          to be_false }
        it { expect(extra_activated_bridge.same?(activated_incoherent_bridge)).
          to be_false }
      end

      describe '#has_termination_atom?' do
        it { expect(bridge.has_termination_atom?(cd, h)).to be_true }
        it { expect(activated_bridge.has_termination_atom?(activated_cd, h)).
          to be_true }
        it { expect(extra_activated_bridge.has_termination_atom?(
          extra_activated_cd, h)). to be_false }

        it { expect(chlorigenated_bridge.has_termination_atom?(cd_chloride, h)).
          to be_true }
        it { expect(chlorigenated_bridge.has_termination_atom?(cd_chloride, cl)).
          to be_true }
      end

      describe '#active_bonds_num' do
        it { expect(bridge.active_bonds_num).to eq(0) }
        it { expect(activated_dimer.active_bonds_num).to eq(1) }
      end

      describe '#size' do
        it { expect(methane.size).to eq(0) }
        it { expect(methyl.size).to eq(0) }
        it { expect(bridge.size).to eq(3) }
        it { expect(hydrogenated_bridge.size).to eq(3.34) }
        it { expect(chlorigenated_bridge.size).to eq(3.34) }
        it { expect(activated_hydrogenated_bridge.size).to eq(3.68) }
        it { expect(extra_activated_bridge.size).to eq(3.68) }
        it { expect(activated_methyl_on_incoherent_bridge.size).to eq(4.47) }
      end

      it_behaves_like 'visitable' do
        subject { methyl }
      end
    end

  end
end
