require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Lattice, use: :engine_generator do
        let(:empty_generator) { stub_generator({}) }
        subject { described_class.new(diamond, empty_generator) }

        describe '#template_name' do
          it { expect(subject.template_name).to eq('lattice') }
        end

        describe '#file_name' do
          it { expect(subject.file_name).to eq('diamond') }
        end

        describe '#define_name' do
          it { expect(subject.define_name).to eq('DIAMOND_H') }
        end

        describe '#class_name' do
          it { expect(subject.class_name).to eq('Diamond') }
        end

        describe '#iterator' do
          let(:iterator) { subject.iterator }
          it { expect(iterator).to be_a(LatticeAtomsIterator) }
        end
      end

    end
  end
end
