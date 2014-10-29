require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentTermination, type: :organizer, use: :atom_properties do
      describe '#parents' do
        it { expect(dept_active_bond.parents).to be_empty }
      end

      describe '<=>' do
        it { expect(dept_active_bond <=> dept_adsorbed_h).to eq(-1) }
        it { expect(dept_adsorbed_h <=> dept_active_bond).to eq(1) }
        it { expect(dept_adsorbed_h <=> dept_adsorbed_cl).to eq(-1) }
        it { expect(dept_adsorbed_cl <=> dept_adsorbed_h).to eq(1) }
      end

      describe '#store_parent' do
        let(:parent) { dept_activated_bridge }
        let(:child) { dept_active_bond }
        before { child.store_parent(parent) }

        it { expect(parent.children).to eq([child]) }
        it { expect(child.parents).to eq([parent]) }
      end

      describe '#terminations_num' do
        it { expect(dept_active_bond.terminations_num(ab_cr)).to eq(1) }
        it { expect(dept_adsorbed_h.terminations_num(hib_ct)).to eq(2) }
      end

      describe '#specific?' do
        it { expect(dept_active_bond.specific?).to be_falsey }
      end
    end

  end
end
