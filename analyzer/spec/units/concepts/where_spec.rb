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

      it_behaves_like 'check specs after swap_source' do
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

      describe '#used_keynames_of' do
        it { expect(at_end.used_keynames_of(dimer).size).to eq(2) }
        it { expect(at_end.used_keynames_of(dimer)).to include(:cr, :cl) }

        it { expect(at_middle.used_keynames_of(dimer).size).to eq(2) }
        it { expect(at_middle.used_keynames_of(dimer)).to include(:cr, :cl) }

        it { expect(near_methyl.used_keynames_of(methyl_on_bridge)).
          to eq([:cb]) }
      end

      it_behaves_like 'visitable' do
        subject { at_end }
      end
    end

  end
end
