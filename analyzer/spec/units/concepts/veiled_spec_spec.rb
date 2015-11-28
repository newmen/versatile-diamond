require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe VeiledSpec do
      describe '#same?' do
        it_behaves_like :check_same_veiled do
          subject { bridge_base }
          let(:other) { dimer_base }
        end

        it_behaves_like :check_same_veiled do
          subject { activated_bridge }
          let(:other) { activated_dimer }
        end
      end

      describe 'veiled bridge' do
        subject { described_class.new(bridge_base) }

        describe '#links' do
          let(:key_atoms) { subject.links.keys }
          let(:value_atoms) { subject.links.flat_map(&:last).map(&:first) }
          let(:atoms) { key_atoms + value_atoms }
          it { expect(atoms.map(&:class).uniq).to eq([VeiledAtom]) }
        end

        describe '#atom' do
          it { expect(subject.atom(:ct)).to be_a(VeiledAtom) }
        end

        describe '#keyname' do
          it { expect(subject.keyname(subject.atom(:ct))).to eq(:ct) }
        end
      end
    end
  end
end
