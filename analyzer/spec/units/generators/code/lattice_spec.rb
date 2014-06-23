require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Lattice, use: :engine_generator do
        let(:empty_generator) { stub_generator({}) }
        subject { described_class.new(diamond, empty_generator) }

        describe '#file_name' do
          it { expect(subject.file_name).to eq('diamond') }
        end

        describe '#class_name' do
          it { expect(subject.class_name).to eq('Diamond') }
        end

        describe '#iterator' do
          let(:iterator) { subject.iterator }
          it { expect(iterator).to be_a(LatticeAtomsIterator) }
          it { expect(iterator.class_name).to eq('DiamondAtomsIterator') }
          it { expect(iterator.file_name).to eq('diamond_atoms_iterator') }
        end
      end

    end
  end
end
