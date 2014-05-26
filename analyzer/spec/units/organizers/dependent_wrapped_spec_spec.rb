require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentWrappedSpec do
      subject { described_class.new(bridge_base) }

      describe '#initialize' do
        describe '#straighten_graph' do
          it { expect(subject.atoms_num).to eq(3) }
          it { expect(subject.relations_num).to eq(10) }
        end
      end

      describe '#gas?' do
        it { expect(subject.gas?).to eq(subject.spec.gas?) }
      end

      describe '#external_bonds' do
        it { expect(subject.external_bonds).to eq(subject.spec.external_bonds) }
      end
    end

  end
end
