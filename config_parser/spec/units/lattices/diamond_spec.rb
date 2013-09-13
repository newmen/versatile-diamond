require 'spec_helper'

describe Diamond do
  subject(:diamond) { described_class.new }

  describe "#opposite_edge" do
    describe "same lattice" do
      describe "bonds" do
        it { expect { diamond.opposite_edge(diamond, free_bond) }.
          to raise_error wrong_relation }

        it { expect { diamond.opposite_edge(diamond, bond_100_cross) }.
          to raise_error wrong_relation }
        it { diamond.opposite_edge(diamond, bond_100_front).
          should == bond_100_front }
        it { diamond.opposite_edge(diamond, bond_110_front).
          should == bond_110_cross }
        it { diamond.opposite_edge(diamond, bond_110_cross).
          should == bond_110_front }
      end

      describe "positions" do
        it { diamond.opposite_edge(diamond, position_front).
          should == position_front }
        it { diamond.opposite_edge(diamond, position_cross).
          should == position_cross }
      end
    end

    describe "other lattice" do
      describe "bonds" do
        it { diamond.opposite_edge(nil, free_bond).should == free_bond }

        it { expect { diamond.opposite_edge(nil, bond_100_front) }.
          to raise_error wrong_relation }
        it { expect { diamond.opposite_edge(nil, bond_100_cross) }.
          to raise_error wrong_relation }
        it { expect { diamond.opposite_edge(nil, bond_110_front) }.
          to raise_error wrong_relation }
        it { expect { diamond.opposite_edge(nil, bond_110_cross) }.
          to raise_error wrong_relation }
      end

      describe "positions" do
        it { expect { diamond.opposite_edge(nil, position_front) }.
          to raise_error wrong_relation }
        it { expect { diamond.opposite_edge(nil, position_cross) }.
          to raise_error wrong_relation }
      end
    end
  end
end
