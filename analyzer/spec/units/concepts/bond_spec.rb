require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Bond do
      describe '#self.[]' do
        it 'if face and dir the same then returns the same instance' do
          {
            {} => free_bond,
            { face: 110, dir: :front } => bond_110_front,
            { face: 110, dir: :cross } => bond_110_cross
          }.each do |hash, bond|
            expect(Bond[hash]).to eq(bond)
          end
        end
      end

      describe '#self.amorph' do
        it { expect(Bond.amorph.face).to be_nil }
        it { expect(Bond.amorph.dir).to be_nil }
      end

      describe '#face' do
        it { expect(free_bond.face).to be_nil }
        it { expect(bond_110_front.face).to eq(110) }
        it { expect(bond_110_cross.face).to eq(110) }
        it { expect(bond_100_front.face).to eq(100) }
        it { expect(bond_100_cross.face).to eq(100) }
      end

      describe '#dir' do
        it { expect(free_bond.dir).to be_nil }
        it { expect(bond_110_front.dir).to eq(:front) }
        it { expect(bond_110_cross.dir).to eq(:cross) }
        it { expect(bond_100_front.dir).to eq(:front) }
        it { expect(bond_100_cross.dir).to eq(:cross) }
      end

      describe '#==' do
        subject { bond_110_front }

        it { expect(subject == Bond.new(110, :front)).to be_truthy }

        it { expect(subject == free_bond).to be_falsey }
        it { expect(subject == position_110_front).to be_falsey }
      end

      describe '#it?' do
        subject { bond_110_front }

        it { expect(subject.it?(face: 110, dir: :front)).to be_truthy }
        it { expect(subject.it?(face: 100, dir: :front)).to be_falsey }
        it { expect(subject.it?(face: 110, dir: :cross)).to be_falsey }
      end

      describe '#same?' do
        it { expect(free_bond.same?(bond_110_front)).to be_truthy }
        it { expect(bond_110_front.same?(free_bond)).to be_truthy }
      end
    end

  end
end
