require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SurfaceSpec do
      describe "#is_gas?" do
        subject { SurfaceSpec.new(:some_surface).is_gas? }
        it { should be_false }
      end

      describe "#link" do
        describe "unspecified atoms" do
          let(:two_c_atoms) { SurfaceSpec.new(:two_c_atoms, c1: c1, c2: c2) }
          let(:unspecified_atoms) { SurfaceSpec::UnspecifiedAtoms }
          it { expect { two_c_atoms.link(c1, c2, free_bond) }.
            to raise_error unspecified_atoms }
          it { expect { two_c_atoms.link(c1, c2, bond_100_front) }.
            to raise_error unspecified_atoms }

          let(:c_and_cd) { SurfaceSpec.new(:c_and_cd, c1: c1, c2: cd2) }
          it { expect { c_and_cd.link(c1, cd2, free_bond) }.
            not_to raise_error }

          let(:cd_and_c) { SurfaceSpec.new(:cd_and_c, c1: cd1, c2: c2) }
          it { expect { cd_and_c.link(cd1, c2, free_bond) }.
            not_to raise_error }

          describe "duplicate position" do
            [:cr, :cl].each do |keyname|
              let(keyname) { bridge_base.atom(keyname) }
            end
            it { expect { bridge_base.link(cl, cr, position_front) }.
              to raise_error position_duplicate }
          end
        end

        describe "specified atoms" do
          let(:two_cd_atoms) do
            SurfaceSpec.new(:two_cd_atoms, c1: cd1, c2: cd2)
          end

          it { expect { two_cd_atoms.link(cd1, cd2, free_bond) }.
            to raise_error wrong_relation }
          it { expect { two_cd_atoms.link(cd1, cd2, bond_100_front) }.
            not_to raise_error }
        end
      end
    end

  end
end
