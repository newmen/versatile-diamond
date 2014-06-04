require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentTermination, use: :atom_properties do
      def wrap(spec)
        described_class.new(spec)
      end

      describe '#parents' do
        it { expect(wrap(active_bond).parents).to be_empty }
      end

      it_behaves_like :multi_parents do
        let(:parent) { DependentSpecificSpec.new(activated_bridge) }
        let(:child) { wrap(active_bond) }
      end

      describe '#terminations_num' do
        it { expect(wrap(active_bond).terminations_num(ab_cr)).to eq(1) }
        it { expect(wrap(adsorbed_h).terminations_num(hib_ct)).to eq(2) }
      end

      describe '#specific?' do
        it { expect(wrap(active_bond).specific?).to be_falsey }
      end
    end

  end
end
