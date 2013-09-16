require 'spec_helper'

describe Diamond do
  subject(:diamond) { described_class.new }

  describe "#opposite_relation" do
    describe "same lattice" do
      describe "bonds" do
        it { expect { diamond.opposite_relation(diamond, free_bond) }.
          to raise_error wrong_relation }

        it { expect { diamond.opposite_relation(diamond, bond_100_cross) }.
          to raise_error wrong_relation }
        it { diamond.opposite_relation(diamond, bond_100_front).
          should == bond_100_front }
        it { diamond.opposite_relation(diamond, bond_110_front).
          should == bond_110_cross }
        it { diamond.opposite_relation(diamond, bond_110_cross).
          should == bond_110_front }
      end

      describe "positions" do
        it { diamond.opposite_relation(diamond, position_front).
          should == position_front }
        it { diamond.opposite_relation(diamond, position_cross).
          should == position_cross }
      end
    end

    describe "other lattice" do
      describe "bonds" do
        it { diamond.opposite_relation(nil, free_bond).should == free_bond }

        it { expect { diamond.opposite_relation(nil, bond_100_front) }.
          to raise_error wrong_relation }
        it { expect { diamond.opposite_relation(nil, bond_100_cross) }.
          to raise_error wrong_relation }
        it { expect { diamond.opposite_relation(nil, bond_110_front) }.
          to raise_error wrong_relation }
        it { expect { diamond.opposite_relation(nil, bond_110_cross) }.
          to raise_error wrong_relation }
      end

      describe "positions" do
        it { expect { diamond.opposite_relation(nil, position_front) }.
          to raise_error wrong_relation }
        it { expect { diamond.opposite_relation(nil, position_cross) }.
          to raise_error wrong_relation }
      end
    end
  end

  describe "#positions_between" do
    describe "position 100 front" do
      let(:links) do {
        cd0 => [[cd1, bond_110_front]],
        cd1 => [[cd0, bond_110_cross], [cd2, bond_110_cross]],
        cd2 => [[cd1, bond_110_front]]
      } end

      it { diamond.positions_between(cd0, cd2, links).
        should == [[position_front, position_front]] }
    end

    describe "position 100 cross" do
      describe "inverted bridge" do
        let(:links) do {
          cd0 => [[cd1, bond_110_cross]],
          cd1 => [[cd0, bond_110_front], [cd2, bond_110_front]],
          cd2 => [[cd1, bond_110_cross]]
        } end

        it { diamond.positions_between(cd0, cd2, links).
          should == [[position_cross, position_cross]] }
      end

      describe "not found positions in dimer fondation because ambiguity" do
        3.times do |i|
          let(:"cd#{i + 3}") { cd.dup }
        end

        let(:links) do {
          cd0 => [[cd1, bond_110_front], [cd3, position_cross]],
          cd1 => [
            [cd0, bond_110_cross], [cd2, bond_110_cross], [cd4, bond_100_front]
          ],
          cd2 => [[cd1, bond_110_front]],
          cd3 => [[cd4, bond_110_front], [cd3, position_cross]],
          cd4 => [
            [cd3, bond_110_cross], [cd5, bond_110_cross], [cd1, bond_100_front]
          ],
          cd5 => [[cd4, bond_110_front]],
        } end

        it { diamond.positions_between(cd2, cd4, links).should == [] }
      end
    end
  end
end
