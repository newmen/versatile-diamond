require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SpecificSpec do
      describe '#dup' do
        it { expect(methyl.dup).not_to eq(methyl) }
        it { expect(methyl.dup.spec).to eq(methyl.spec) }
        it { expect(methyl.dup.external_bonds).to eq(3) }

        describe 'extended' do
          subject { activated_methyl_on_extended_bridge.dup }
          it { expect(subject.extended?).to be_truthy }
          it { expect(subject.reduced).not_to eq(activated_methyl_on_bridge) }
        end
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

      describe '#replace_base_spec' do
        before { activated_dimer.replace_base_spec(dimer_base_dup) }
        it { expect(activated_dimer.spec).to eq(dimer_base_dup) }
        it { expect(activated_dimer.name).to eq(:'dimer(r: *)') }

        describe 'intersec is not full' do
          let(:spec) { activated_methyl_on_bridge }
          before { spec.replace_base_spec(bridge_base_dup) }
          it { expect(spec.name).to eq(:'methyl_on_bridge(cm: *)') }
          it { expect(spec.atom(:t)).to eq(bridge_base_dup.atom(:t)) }
          it { expect(spec.atom(:cm)).to eq(activated_methyl_on_bridge.atom(:cm)) }
          it { expect(spec.links.size).to eq(4) }

          describe 'correct atoms from links' do
            def get_by(method)
              spec.links.public_send(:"#{method}_by") { |_, l| l.size }.first
            end

            it { expect(get_by(:max)).to eq(spec.atom(:t)) }
            it { expect(get_by(:min)).to eq(spec.atom(:cm)) }
          end
        end
      end

      describe '#position_between' do
        shared_examples_for :position_between_two_atoms do
          let(:atom1) { spec.atom(keyname1) }
          let(:atom2) { spec.atom(keyname2) }
          it { expect(spec.position_between(atom1, atom2)).to eq(position) }
        end

        describe 'activated dimer' do
          let(:spec) { activated_dimer }
          let(:position) { position_100_front }

          it_behaves_like :position_between_two_atoms do
            let(:keyname1) { :cr }
            let(:keyname2) { :cl }
          end

          it_behaves_like :position_between_two_atoms do
            let(:keyname1) { :cl }
            let(:keyname2) { :cr }
          end
        end

        describe 'activated methyl on incoherent bridge' do
          let(:spec) { activated_methyl_on_incoherent_bridge }
          let(:position) { nil }

          it_behaves_like :position_between_two_atoms do
            let(:keyname1) { :cm }
            let(:keyname2) { :cb }
          end

          it_behaves_like :position_between_two_atoms do
            let(:keyname1) { :cb }
            let(:keyname2) { :cm }
          end
        end
      end

      describe '#name' do
        it { expect(methane.name).to eq(:'methane()') }
        it { expect(methyl.name).to eq(:'methane(c: *)') }

        it { expect(bridge.name).to eq(:'bridge()') }
        it { expect(activated_bridge.name).to eq(:'bridge(ct: *)') }
        it { expect(extra_activated_bridge.name).to eq(:'bridge(ct: *, ct: *)') }
        it { expect(hydrogenated_bridge.name).to eq(:'bridge(ct: H)') }
        it { expect(activated_hydrogenated_bridge.name).
          to eq(:'bridge(ct: *, ct: H)') }
        it { expect(activated_incoherent_bridge.name).
          to eq(:'bridge(ct: *, ct: i)') }

        it { expect(methyl_on_bridge.name).to eq(:'methyl_on_bridge()') }
        it { expect(activated_methyl_on_bridge.name).
          to eq(:'methyl_on_bridge(cm: *)') }
        it { expect(unfixed_methyl_on_bridge.name).
          to eq(:'methyl_on_bridge(cm: u)') }
        it { expect(methyl_on_activated_bridge.name).
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
        it { expect(activated_dimer.keyname(activated_dimer.atom(:cl))).to eq(:cl) }
      end

      describe '#describe_atom' do
        before { bridge.describe_atom(:ct, activated_cd) }
        it { expect(bridge.atom(:ct)).to eq(activated_cd) }
        it { expect(bridge.keyname(activated_cd)).to eq(:ct) }
      end

      describe '#links' do
        it { expect(methyl.links).to match_graph({ activated_c => [] }) }
        it { expect(vinyl.links).to match_graph({
          activated_c => [[c2, free_bond], [c2, free_bond]],
          c2 => [[activated_c, free_bond], [activated_c, free_bond]] }) }
      end

      describe '#gas?' do
        it { expect(hydrogen.gas?).to be_truthy }
        it { expect(hydrogen_ion.gas?).to be_truthy }
        it { expect(methane.gas?).to be_truthy }
        it { expect(methyl.gas?).to be_truthy }
        it { expect(bridge.gas?).to be_falsey }
        it { expect(extra_activated_bridge.gas?).to be_falsey }
      end

      describe '#simple?' do
        it { expect(hydrogen.simple?).to be_truthy }
        it { expect(hydrogen_ion.simple?).to be_truthy }
        it { expect(methane.simple?).to be_falsey }
        it { expect(methyl.simple?).to be_falsey }
        it { expect(bridge.simple?).to be_falsey }
        it { expect(extra_activated_bridge.simple?).to be_falsey }
      end

      describe '#incoherent!' do
        before { activated_bridge.incoherent!(:ct) }
        it { expect(activated_cd.incoherent?).to be_truthy }
      end

      describe '#unfixed!' do
        before { activated_methyl_on_bridge.unfixed!(:cm) }
        it { expect(activated_c.unfixed?).to be_truthy }
      end

      describe '#relation_between' do
        let_atoms_of(:activated_bridge, [:ct, :cr])
        it { expect(activated_bridge.relation_between(ct, cr)).to eq(bond_110_cross) }
        it { expect(activated_bridge.relation_between(cr, ct)).to eq(bond_110_front) }
      end

      describe '#external_bonds_for' do
        it { expect(methane.external_bonds_for(c)).to eq(4) }
        it { expect(methyl.external_bonds_for(activated_c)).to eq(3) }
        it { expect(bridge.external_bonds_for(cd)).to eq(2) }
        it { expect(activated_bridge.external_bonds_for(activated_cd)).to eq(1) }
        it { expect(chlorigenated_bridge.external_bonds_for(cd_chloride)).to eq(1) }
        it { expect(methyl_on_bridge.external_bonds_for(c)).to eq(3) }
        it { expect(methyl_on_activated_bridge.external_bonds_for(c)).to eq(3) }
        it { expect(methyl_on_activated_bridge.external_bonds_for(activated_cd)).
          to eq(0) }
        it { expect(extra_activated_bridge.external_bonds_for(extra_activated_cd)).
          to eq(0) }
        it { expect(activated_methyl_on_bridge.external_bonds_for(activated_c)).
          to eq(2) }
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
        it { expect(chlorigenated_bridge.external_bonds).to eq(4) }#3) }
      end

      describe '#extended?' do
        it { expect(bridge.extended?).to be_falsey }
        it { expect(dimer.extended?).to be_falsey }

        it { expect(activated_methyl_on_extended_bridge.extended?).to be_truthy }
        it { expect(right_activated_extended_bridge.extended?).to be_truthy }
        it { expect(extended_dimer.extended?).to be_truthy }
      end

      describe '#reduced' do
        it { expect(bridge.reduced).to be_nil }
        it { expect(dimer.reduced).to be_nil }

        it { expect(activated_methyl_on_extended_bridge.reduced).
          not_to eq(activated_methyl_on_bridge) }
        it { expect(right_activated_extended_bridge.reduced).
          not_to eq(right_activated_bridge) }
        it { expect(extended_dimer.reduced).not_to eq(dimer) }
      end

      describe '#extendable?' do
        it { expect(methane.extendable?).to be_falsey }
        it { expect(methyl.extendable?).to be_falsey }
        it { expect(bridge.extendable?).to be_truthy }
        it { expect(extra_activated_bridge.extendable?).to be_truthy }
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
        it { expect(activated_methyl_on_extended_bridge.could_be_reduced?).to be_truthy }
        it { expect(right_activated_extended_bridge.could_be_reduced?).to be_truthy }
        it { expect(extended_dimer.could_be_reduced?).to be_truthy }
      end

      describe '#same?' do
        it { expect(methyl.same?(methyl.dup)).to be_truthy }
        it { expect(bridge.same?(bridge.dup)).to be_truthy }

        it { expect(methyl.same?(active_bond)).to be_falsey }
        it { expect(methyl.same?(adsorbed_h)).to be_falsey }

        it { expect(methyl.same?(bridge)).to be_falsey }
        it { expect(bridge.same?(activated_bridge)).to be_falsey }
        it { expect(activated_bridge.same?(activated_incoherent_bridge)).to be_falsey }
        it { expect(activated_bridge.same?(extra_activated_bridge)).to be_falsey }
        it { expect(extra_activated_bridge.same?(activated_incoherent_bridge)).
          to be_falsey }

        it { expect(activated_bridge.same?(bridge_base)).to be_falsey }
      end

      describe '#has_termination?' do
        it { expect(bridge.has_termination?(cd, adsorbed_h)).to be_truthy }
        it { expect(activated_bridge.has_termination?(activated_cd, adsorbed_h)).
          to be_truthy }

        let(:ea_bridge) { extra_activated_bridge }
        it { expect(ea_bridge.has_termination?(extra_activated_cd, adsorbed_h)).
          to be_falsey }

        let(:cl_bridge) { chlorigenated_bridge }
        it { expect(cl_bridge.has_termination?(cd_chloride, adsorbed_h)).to be_truthy }
        it { expect(cl_bridge.has_termination?(cd_chloride, adsorbed_cl)).
          to be_truthy }
      end

      describe '#active_bonds_num' do
        it { expect(bridge.active_bonds_num).to eq(0) }
        it { expect(activated_dimer.active_bonds_num).to eq(1) }
      end
    end

  end
end
