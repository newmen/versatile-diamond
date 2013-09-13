require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe GasSpec do
      describe "#is_gas?" do
        subject { GasSpec.new(:some_gas).is_gas? }
        it { should be_true }
      end

      describe "#link" do
        let(:two_c_atoms) { GasSpec.new(:two_c_atoms, c1: c1, c2: c2) }

        describe "check bonds number" do
          before(:each) do
            s = two_c_atoms
            s.link(c1, c2, free_bond)
            s.link(c1, c2, free_bond)
            s.link(c1, c2, free_bond)
            s.link(c1, c2, free_bond)
          end

          it { expect { two_c_atoms.link(c1, c2, free_bond) }.
            to raise_error Atom::IncorrectValence }
        end

        describe "wrong bond" do
          it { expect { two_c_atoms.link(c1, c2, bond_100_front) }.
            to raise_error wrong_relation }
        end
      end
    end

  end
end
