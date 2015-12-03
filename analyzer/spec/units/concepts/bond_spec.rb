require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Bond do
      describe '#self.[]' do
        it 'if face and dir the same then returns the same instance' do
          {
            {} => free_bond,
            param_110_front => bond_110_front,
            param_110_cross => bond_110_cross
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

      describe '#<=>' do
        it { expect(bond_100_front <=> position_110_front).to eq(-1) }
        it { expect(position_110_front <=> bond_100_front).to eq(1) }
        it { expect(bond_100_front <=> bond_110_front).to eq(-1) }
        it { expect(bond_110_front <=> bond_100_front).to eq(1) }
        it { expect(bond_100_cross <=> bond_100_front).to eq(-1) }
        it { expect(bond_100_front <=> bond_100_cross).to eq(1) }
        it { expect(bond_100_front <=> free_bond).to eq(-1) }
        it { expect(free_bond <=> bond_100_front).to eq(1) }
      end

      describe '#cross' do
        it { expect(bond_100_front.cross).to eq(bond_100_cross) }
        it { expect(bond_100_cross.cross).to eq(bond_100_front) }
      end

      describe '#params' do
        it { expect(free_bond.params).to eq(param_amorph) }
        it { expect(bond_110_front.params).to eq(param_110_front) }
        it { expect(bond_100_cross.params).to eq(param_100_cross) }
      end

      describe '#make_position' do
        it { expect(bond_100_front.make_position).to eq(position_100_front) }
        it { expect(bond_110_cross.make_position).to eq(position_110_cross) }
        it { expect { free_bond.make_position }.to raise_error }
      end

      describe '#it?' do
        subject { bond_110_front }

        it { expect(subject.it?(face: 110, dir: :front)).to be_truthy }
        it { expect(subject.it?(face: 100, dir: :front)).to be_falsey }
        it { expect(subject.it?(param_110_front)).to be_truthy }
        it { expect(subject.it?(param_110_cross)).to be_falsey }
      end

      describe '#same?' do
        it { expect(free_bond.same?(bond_110_front)).to be_truthy }
        it { expect(bond_110_front.same?(free_bond)).to be_truthy }
        it { expect(bond_110_front.same?(position_110_front)).to be_truthy }
        it { expect(bond_110_front.same?(position_100_front)).to be_falsey }
        it { expect(bond_110_front.same?(non_position_110_front)).to be_falsey }
      end

      describe '#belongs_to_crystal?' do
        it { expect(free_bond.belongs_to_crystal?).to be_falsey }
        it { expect(bond_100_front.belongs_to_crystal?).to be_truthy }
      end

      describe '#exist?' do
        it { expect(free_bond.exist?).to be_truthy }
        it { expect(bond_100_front.exist?).to be_truthy }
      end
    end

  end
end
