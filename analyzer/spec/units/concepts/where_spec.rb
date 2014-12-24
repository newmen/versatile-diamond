require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Where do
      describe '#specs' do
        it { expect(at_end.specs).to eq([dimer]) }
        it { expect(at_middle.specs).to eq([dimer]) }
        it { expect(near_methyl.specs).to eq([methyl_on_bridge]) }
      end

      describe '#description' do
        it { expect(at_end.description).to eq('at end of dimers row') }
      end

      it_behaves_like :check_specs_after_swap_source do
        subject { at_end }
        let(:method) { :specs }
      end

      describe '#parents' do
        it { expect(at_end.parents).to be_empty }
        it { expect(at_middle.parents).to eq([at_end]) }
      end

      describe '#concretize' do
        it { expect(near_methyl.concretize(target: [bridge, bridge.atom(:ct)])).
          to be_a(There) }

        # TODO: check positions
      end
    end

  end
end
