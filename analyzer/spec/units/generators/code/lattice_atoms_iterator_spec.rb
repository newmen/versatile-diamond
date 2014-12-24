require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe LatticeAtomsIterator, use: :engine_generator do
        let(:empty_generator) { stub_generator({}) }
        let(:lattice) { Lattice.new(empty_generator, diamond) }
        subject { described_class.new(lattice) }

        describe '#template_name' do
          it { expect(subject.template_name).to eq('lattice_atoms_iterator') }
        end

        describe '#file_name' do
          it { expect(subject.file_name).to eq('diamond_atoms_iterator') }
        end

        describe '#define_name' do
          it { expect(subject.define_name).to eq('DIAMOND_ATOMS_ITERATOR_H') }
        end

        describe '#class_name' do
          it { expect(subject.class_name).to eq('DiamondAtomsIterator') }
        end
      end

    end
  end
end
