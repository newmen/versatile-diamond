require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Spec do
      describe "self#good_for_reduce?" do
        it { expect(described_class.good_for_reduce?([:cl])).to be_true }
        it { expect(described_class.good_for_reduce?([:_cl])).to be_false }
      end

      describe "#simple?" do
        it { expect(Spec.new(:not_set).simple?).to be_nil }

        it { expect(hydrogen_base.simple?).to be_true }
        it { expect(methane_base.simple?).not_to be_true }
        it { expect(ethylene_base.simple?).not_to be_true }
        it { expect(bridge_base.simple?).not_to be_true }
      end

      describe "#atom" do
        it { expect(methane_base.atom(:w)).to be_nil }
        it { expect(methane_base.atom(:c)).to eq(c) }
      end

      describe "#keyname" do
        it { expect(methane_base.keyname(c)).to eq(:c) }
        it { expect(bridge_base.keyname(cd)).to eq(:ct) }
      end

      describe "#describe_atom" do
        it "atom stores to spec" do
          spec = Spec.new(:some)
          spec.describe_atom(:c, c)
          expect(spec.atom(:c)).to eq(c)
        end
      end

      describe "#rename_atom" do
        describe "old atom keyname changes to new keyname" do
          before(:each) { methane_base.rename_atom(:c, :new_c) }
          it { expect(methane_base.atom(:new_c)).to eq(c) }
        end

        describe "if keyname already exist before renaming it" do
          before(:each) { ethylene_base.rename_atom(:c1, :c2) }
          it { expect(ethylene_base.atom(:c1)).to be_nil }
          it { expect(ethylene_base.atom(:c2)).to eq(c1) }
          it { expect(ethylene_base.size).to eq(2) }
        end
      end

      describe "#links" do
        it { expect(methane_base.links).to eq({ c => [] }) }
        it { expect(ethylene_base.links).to eq({
          c1 => [[c2, free_bond], [c2, free_bond]],
          c2 => [[c1, free_bond], [c1, free_bond]] }) }
      end

      describe "#adsorb" do
        describe "methane adsorbs each atom and links of ethylene" do
          subject { methane_base }
          before(:each) { subject.adsorb(ethylene_base) }
          it { expect(subject.external_bonds_for(subject.atom(:c))).to eq(4) }
          it { expect(subject.external_bonds_for(subject.atom(:c1))).to eq(2) }
          it { expect(subject.external_bonds_for(subject.atom(:c2))).to eq(2) }
        end
      end

      describe "#external_bonds_for" do
        describe "methane" do
          subject { methane_base }
          it { expect(subject.external_bonds_for(subject.atom(:c))).to eq(4) }
        end

        describe "ethylene" do
          subject { ethylene_base }
          it { expect(subject.external_bonds_for(subject.atom(:c1))).to eq(2) }
          it { expect(subject.external_bonds_for(subject.atom(:c2))).to eq(2) }
        end

        describe "bridge" do
          subject { bridge_base }
          it { expect(subject.external_bonds_for(subject.atom(:ct))).to eq(2) }
          it { expect(subject.external_bonds_for(subject.atom(:cl))).to eq(1) }
          it { expect(subject.external_bonds_for(subject.atom(:cr))).to eq(1) }
        end

        describe "methyl on bridge" do
          subject { methyl_on_bridge_base }
          it { expect(subject.external_bonds_for(subject.atom(:cm))).to eq(3) }
          it { expect(subject.external_bonds_for(subject.atom(:cb))).to eq(1) }
          it { expect(subject.external_bonds_for(subject.atom(:cl))).to eq(1) }
          it { expect(subject.external_bonds_for(subject.atom(:cr))).to eq(1) }
        end

        describe "methyl on dimer" do
          subject { methyl_on_dimer_base }
          it { expect(subject.external_bonds_for(subject.atom(:cm))).to eq(3) }
          it { expect(subject.external_bonds_for(subject.atom(:cr))).to eq(0) }
          it { expect(subject.external_bonds_for(subject.atom(:cl))).to eq(1) }
        end
      end

      describe "#external_bonds" do
        it { expect(hydrogen_base.external_bonds).to eq(2) }
        it { expect(methane_base.external_bonds).to eq(4) }
        it { expect(ethylene_base.external_bonds).to eq(4) }
        it { expect(bridge_base.external_bonds).to eq(4) }
      end

      describe "#extendable?" do
        it { expect(methane_base.extendable?).to be_false }
        it { expect(ethylene_base.extendable?).to be_false }
        it { expect(bridge_base.extendable?).to be_true }
      end

      describe "#extend_by_references" do
        it { expect(extended_bridge_base.external_bonds).to eq(8) }
        it { expect(methyl_on_extended_bridge_base.external_bonds).to eq(10) }
        it { expect(methyl_on_dimer_base.extend_by_references.external_bonds).
          to eq(16) } # if take into account the crystal lattice then value
          # should be 10
      end

      describe "#links_with_replace_by" do
        let(:links) { ethylene_base.links_with_replace_by(c2: o) }

        it { expect(links.include?(o)).to be_true }
        it { expect(links[c1].select { |a, _| a == o }.size).to eq(2) }
      end

      describe "#parent" do
        it { expect(bridge_base.parent).to be_nil } # by default
      end

      describe "#organize_dependencies!" do
        before { methyl_on_bridge_base.organize_dependencies!([bridge_base]) }
        it { expect(methyl_on_bridge_base.parent).to eq(bridge_base) }
      end

      describe "#theres" do
        it { expect(dimer_base.theres).to be_empty }
      end

      describe "#store_there" do
        before { dimer_base.store_there(on_end) }
        it { expect(dimer_base.theres).to match_array([on_end]) }
      end

      describe "#childs" do
        it { expect(dimer_base.childs).to be_empty }
      end

      describe "#store_child" do
        before { dimer_base.store_child(methyl_on_dimer_base) }
        it { expect(dimer_base.childs).to match_array([methyl_on_dimer_base]) }
      end

      describe "#append_childs" do
        before { dimer_base.append_childs([activated_dimer]) }
        it { expect(dimer_base.childs).to match_array([activated_dimer]) }
      end

      describe "#remove_child" do
        before do
          dimer_base.store_child(dimer)
          dimer_base.remove_child(dimer)
        end
        it { expect(dimer_base.childs).to be_empty }
      end

      describe "#size" do
        it { expect(hydrogen_base.size).to eq(1) }
        it { expect(methane_base.size).to eq(1) }
        it { expect(ethylene_base.size).to eq(2) }
        it { expect(bridge_base.size).to eq(3) }
        it { expect(methyl_on_bridge_base.size).to eq(4) }
        it { expect(methyl_on_extended_bridge_base.size).to eq(8) }
        it { expect(high_bridge_base.size).to eq(4) }
        it { expect(dimer_base.size).to eq(6) }
        it { expect(extended_dimer_base.size).to eq(14) } # if take into account the
        # crystal lattice then value should be 12
        it { expect(methyl_on_dimer_base.size).to eq(7) }
      end

      it_behaves_like "visitable" do
        subject { methane_base }
      end
    end

  end
end
