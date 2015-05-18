require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Where do
      describe '#specs' do
        it { expect(at_end.specs).to eq([dimer]) }
        it { expect(at_middle.specs).to eq([dimer_dup]) }
        it { expect(near_methyl.specs).to eq([methyl_on_bridge]) }
      end

      describe '#all_specs' do
        it { expect(at_end.all_specs).to match_array([dimer]) }
        it { expect(at_middle.all_specs).to match_array([dimer, dimer_dup]) }
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
      end

      describe '#used_atoms_of' do
        let(:atoms) { [dimer.atom(:cl), dimer.atom(:cr)] }
        it { expect(at_end.used_atoms_of(dimer)).to match_array(atoms) }
      end

      describe '#same_positions?' do
        it { expect(at_end.same_positions?(at_middle)).to be_truthy }
        it { expect(at_middle.same_positions?(at_end)).to be_truthy }

        it { expect(near_methyl.same_positions?(at_end)).to be_falsey }
        it { expect(at_end.same_positions?(near_methyl)).to be_falsey }
      end
    end

  end
end
