require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Spec do
      describe 'self#good_for_reduce?' do
        it { expect(described_class.good_for_reduce?([:cl])).to be_truthy }
        it { expect(described_class.good_for_reduce?([:_cl])).to be_falsey }
      end

      describe '#simple?' do
        it { expect(Spec.new(:not_set).simple?).to be_nil }

        it { expect(hydrogen_base.simple?).to be_truthy }
        it { expect(methane_base.simple?).not_to be_truthy }
        it { expect(ethylene_base.simple?).not_to be_truthy }
        it { expect(bridge_base.simple?).not_to be_truthy }
      end

      describe '#atom' do
        it { expect(methane_base.atom(:w)).to be_nil }
        it { expect(methane_base.atom(:c)).to eq(c) }
      end

      describe '#keyname' do
        it { expect(methane_base.keyname(c)).to eq(:c) }
        it { expect(bridge_base.keyname(cd)).to eq(:ct) }
      end

      describe '#describe_atom' do
        it 'atom stores to spec' do
          spec = Spec.new(:some)
          spec.describe_atom(:c, c)
          expect(spec.atom(:c)).to eq(c)
        end
      end

      describe '#rename_atom' do
        describe 'old atom keyname changes to new keyname' do
          before(:each) { methane_base.rename_atom(:c, :new_c) }
          it { expect(methane_base.atom(:new_c)).to eq(c) }
        end

        describe 'if keyname already exist before renaming it' do
          before(:each) { ethylene_base.rename_atom(:c1, :c2) }
          it { expect(ethylene_base.atom(:c1)).to be_nil }
          it { expect(ethylene_base.atom(:c2)).to eq(c1) }
          it { expect(ethylene_base.links.size).to eq(2) }
        end
      end

      describe '#links' do
        it { expect(methane_base.links).to match_graph({ c => [] }) }
        it { expect(ethylene_base.links).to match_graph({
          c1 => [[c2, free_bond], [c2, free_bond]],
          c2 => [[c1, free_bond], [c1, free_bond]] }) }
      end

      describe '#adsorb' do
        describe 'methane adsorbs each atom and links of ethylene' do
          subject { methane_base }
          before(:each) { subject.adsorb(ethylene_base) }
          it { expect(subject.external_bonds_for(subject.atom(:c))).to eq(4) }
          it { expect(subject.external_bonds_for(subject.atom(:c1))).to eq(2) }
          it { expect(subject.external_bonds_for(subject.atom(:c2))).to eq(2) }
        end
      end

      describe '#relation_between' do
        let(:ct) { bridge_base.atom(:ct) }
        let(:cr) { bridge_base.atom(:cr) }
        it { expect(bridge_base.relation_between(ct, cr)).to eq(bond_110_cross) }
        it { expect(bridge_base.relation_between(cr, ct)).to eq(bond_110_front) }
      end

      describe '#external_bonds_for' do
        describe 'methane' do
          subject { methane_base }
          it { expect(subject.external_bonds_for(subject.atom(:c))).to eq(4) }
        end

        describe 'ethylene' do
          subject { ethylene_base }
          it { expect(subject.external_bonds_for(subject.atom(:c1))).to eq(2) }
          it { expect(subject.external_bonds_for(subject.atom(:c2))).to eq(2) }
        end

        describe 'bridge' do
          subject { bridge_base }
          it { expect(subject.external_bonds_for(subject.atom(:ct))).to eq(2) }
          it { expect(subject.external_bonds_for(subject.atom(:cl))).to eq(1) }
          it { expect(subject.external_bonds_for(subject.atom(:cr))).to eq(1) }
        end

        describe 'methyl on bridge' do
          subject { methyl_on_bridge_base }
          it { expect(subject.external_bonds_for(subject.atom(:cm))).to eq(3) }
          it { expect(subject.external_bonds_for(subject.atom(:cb))).to eq(1) }
          it { expect(subject.external_bonds_for(subject.atom(:cl))).to eq(1) }
          it { expect(subject.external_bonds_for(subject.atom(:cr))).to eq(1) }
        end

        describe 'methyl on dimer' do
          subject { methyl_on_dimer_base }
          it { expect(subject.external_bonds_for(subject.atom(:cm))).to eq(3) }
          it { expect(subject.external_bonds_for(subject.atom(:cr))).to eq(0) }
          it { expect(subject.external_bonds_for(subject.atom(:cl))).to eq(1) }
        end
      end

      describe '#external_bonds' do
        it { expect(hydrogen_base.external_bonds).to eq(2) }
        it { expect(methane_base.external_bonds).to eq(4) }
        it { expect(ethylene_base.external_bonds).to eq(4) }
        it { expect(bridge_base.external_bonds).to eq(4) }
      end

      describe '#extendable?' do
        it { expect(methane_base.extendable?).to be_falsey }
        it { expect(ethylene_base.extendable?).to be_falsey }
        it { expect(bridge_base.extendable?).to be_truthy }
      end

      describe '#extend_by_references' do
        it { expect(extended_bridge_base.external_bonds).to eq(8) }
        it { expect(methyl_on_extended_bridge_base.external_bonds).to eq(10) }
        it { expect(methyl_on_dimer_base.extend_by_references.external_bonds).
          to eq(16) } # if take into account the crystal lattice then value
          # should be 10
      end

      describe '#links_with_replace_by' do
        let(:links) { ethylene_base.links_with_replace_by(c2: o) }

        it { expect(links.include?(o)).to be_truthy }
        it { expect(links[c1].select { |a, _| a == o }.size).to eq(2) }
      end

      describe '#has_termination?' do
        describe 'bridge(:ct)' do
          let(:atom) { bridge_base.atom(:ct) }
          it { expect(bridge_base.has_termination?(atom, adsorbed_h)).to be_truthy }
          it { expect(bridge_base.has_termination?(atom, active_bond)).to be_falsey }
        end

        describe 'methyl_on_dimer(:cr)' do
          let(:target) { methyl_on_dimer }
          let(:atom) { target.atom(:cr) }
          it { expect(target.has_termination?(atom, adsorbed_h)).to be_falsey }
          it { expect(target.has_termination?(atom, active_bond)).to be_falsey }
        end
      end

      describe '#same?' do
        describe 'bridge_base' do
          let(:same_bridge) { bridge_base_dup }
          subject { bridge_base }

          it { expect(subject.same?(same_bridge)).to be_truthy }
          it { expect(same_bridge.same?(subject)).to be_truthy }

          it { expect(subject.same?(dimer_base)).to be_falsey }
        end

        describe 'methyl_on_bridge_base' do
          let(:other) { high_bridge_base }
          subject { methyl_on_bridge_base }

          it { expect(subject.same?(other)).to be_falsey }
          it { expect(other.same?(subject)).to be_falsey }
        end
      end
    end

  end
end
