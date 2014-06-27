require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentTermination, type: :organizer, use: :atom_properties do
      describe '#parents' do
        it { expect(dept_active_bond.parents).to be_empty }
      end

      it_behaves_like :multi_parents do
        let(:parent) { dept_activated_bridge }
        let(:child) { dept_active_bond }
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
