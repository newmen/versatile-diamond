require 'spec_helper'

describe Diamond do
  subject(:diamond) { described_class.new }

  describe '#opposite_relation' do
    describe 'same lattice' do
      describe 'bonds' do
        it { expect { diamond.opposite_relation(diamond, free_bond) }.
          to raise_error undefined_relation }

        it { expect { diamond.opposite_relation(diamond, bond_100_cross) }.
          to raise_error undefined_relation }
        it { expect(diamond.opposite_relation(diamond, bond_100_front)).
          to eq(bond_100_front) }
        it { expect(diamond.opposite_relation(diamond, bond_110_front)).
          to eq(bond_110_cross) }
        it { expect(diamond.opposite_relation(diamond, bond_110_cross)).
          to eq(bond_110_front) }
      end

      describe 'positions' do
        it { expect(diamond.opposite_relation(diamond, position_100_front)).
          to eq(position_100_front) }
        it { expect(diamond.opposite_relation(diamond, position_100_cross)).
          to eq(position_100_cross) }
      end
    end

    describe 'other lattice' do
      describe 'bonds' do
        it { expect(diamond.opposite_relation(nil, free_bond)).
          to eq(free_bond) }

        it { expect { diamond.opposite_relation(nil, bond_100_front) }.
          to raise_error undefined_relation }
        it { expect { diamond.opposite_relation(nil, bond_100_cross) }.
          to raise_error undefined_relation }
        it { expect { diamond.opposite_relation(nil, bond_110_front) }.
          to raise_error undefined_relation }
        it { expect { diamond.opposite_relation(nil, bond_110_cross) }.
          to raise_error undefined_relation }
      end

      describe 'positions' do
        it { expect { diamond.opposite_relation(nil, position_100_front) }.
          to raise_error undefined_relation }
        it { expect { diamond.opposite_relation(nil, position_100_cross) }.
          to raise_error undefined_relation }
      end
    end
  end

  describe '#positions_between' do
    describe 'position 100 front' do
      let(:poss) { [position_100_front, position_100_front] }
      let(:links) do {
        cd0 => [[cd1, bond_110_front]],
        cd1 => [[cd0, bond_110_cross], [cd2, bond_110_cross]],
        cd2 => [[cd1, bond_110_front]]
      } end

      it { expect(diamond.positions_between(cd0, cd2, links)).to match_array(poss) }
      it { expect(diamond.positions_between(cd2, cd0, links)).to match_array(poss) }

      describe 'in three bridges' do
        let(:links) { three_bridges_base.links }
        let(:a1) { three_bridges_base.atom(:cc) }
        let(:a2) { three_bridges_base.atom(:ct) }

        it { expect(diamond.positions_between(a1, a2, links)).to match_array(poss) }
        it { expect(diamond.positions_between(a2, a1, links)).to match_array(poss) }
      end
    end

    describe 'position 100 cross' do
      describe 'inverted bridge' do
        let(:links) do {
          cd0 => [[cd1, bond_110_cross]],
          cd1 => [[cd0, bond_110_front], [cd2, bond_110_front]],
          cd2 => [[cd1, bond_110_cross]]
        } end

        it { expect(diamond.positions_between(cd0, cd2, links)).
          to match_array([position_100_cross, position_100_cross]) }
      end

      describe 'not found positions in dimer fondation because ambiguity' do
        3.times do |i|
          let(:"cd#{i + 3}") { cd.dup }
        end

        let(:links) do {
          cd0 => [[cd1, bond_110_front], [cd3, position_100_cross]],
          cd1 => [[cd0, bond_110_cross], [cd2, bond_110_cross], [cd4, bond_100_front]],
          cd2 => [[cd1, bond_110_front]],
          cd3 => [[cd4, bond_110_front], [cd3, position_100_cross]],
          cd4 => [[cd3, bond_110_cross], [cd5, bond_110_cross], [cd1, bond_100_front]],
          cd5 => [[cd4, bond_110_front]],
        } end

        it { expect(diamond.positions_between(cd2, cd4, links)).to be_nil }
      end
    end
  end
end
