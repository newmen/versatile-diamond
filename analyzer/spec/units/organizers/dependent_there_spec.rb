require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentThere do
      subject { described_class.new(there_methyl) }

      describe '#each_source' do
        it { expect(subject.each_source).to be_a(Enumerator) }
        it { expect(subject.each_source.to_a).to eq([methyl_on_bridge]) }
      end

      describe '#where' do
        it { expect(subject.where).to eq(near_methyl) }
      end

      describe '#swap_source' do
        let(:mob_dup) { methyl_on_bridge.dup }
        before { subject.swap_source(methyl_on_bridge, mob_dup) }
        it { expect(subject.each_source.to_a).to eq([mob_dup]) }
      end

      describe '#used_atoms_of' do
        let(:atoms) { [methyl_on_bridge.atom(:cb)] }
        it { expect(subject.used_atoms_of(methyl_on_bridge)).to eq(atoms) }
      end
    end

  end
end
