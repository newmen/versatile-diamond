require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SurfaceSpec do
      describe '#dup' do
        describe 'new name and atoms' do
          before { bridge_base_dup.rename_atom(:t, :YY) }

          it { expect(bridge_base.atom(:YY)).to be_nil }
          it { expect(bridge_base_dup.atom(:YY)).not_to be_nil }
        end

        describe 'same name and atoms' do
          let(:copy) { bridge_base.dup }

          it { expect(copy).not_to eq(bridge_base) }
          it { expect(bridge_base).not_to eq(copy) }
          it { expect(copy).not_to eq(bridge_base_dup) }
          it { expect(bridge_base_dup).not_to eq(copy) }

          it { expect(copy.name).to eq(bridge_base.name) }
          it { expect(copy.links).not_to eq(bridge_base.links) }
        end
      end

      describe '#gas?' do
        subject { SurfaceSpec.new(:some_surface).gas? }
        it { should be_falsey }
      end

      describe '#link' do
        describe 'unspecified atoms' do
          let(:two_c_atoms) { SurfaceSpec.new(:two_c_atoms, c1: c1, c2: c2) }
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

          describe 'duplicate position' do
            let_atoms_of(:bridge_base, [:cr, :cl])
            it { expect { bridge_base.link(cl, cr, position_100_front) }.
              to raise_error position_duplicate }
          end
        end

        describe 'specified atoms' do
          let(:two_cd_atoms) do
            SurfaceSpec.new(:two_cd_atoms, c1: cd1, c2: cd2)
          end

          it { expect { two_cd_atoms.link(cd1, cd2, free_bond) }.
            to raise_error undefined_relation }
          it { expect { two_cd_atoms.link(cd1, cd2, bond_100_front) }.
            not_to raise_error }
        end

        describe 'same atom' do
          subject { SurfaceSpec.new(:spec, cd1: cd1, cd2: cd1) }
          it { expect { subject.link(cd1, cd1, bond_100_front) }.
            to raise_error Linker::SameAtom }
        end
      end

      describe '#position_between' do
        describe 'simple specs' do
          describe 'two on 100' do
            let(:two_on_100) { SurfaceSpec.new(:two_on_100, c1: cd1, c2: cd2) }
            before { two_on_100.link(cd1, cd2, bond_100_front) }
            it { expect(two_on_100.position_between(cd1, cd2)).
              to eq(position_100_front) }
          end

          describe 'two on 110' do
            let(:two_on_110) { SurfaceSpec.new(:two_on_110, c1: cd1, c2: cd2) }
            before(:each) { two_on_110.link(cd1, cd2, bond_110_front) }

            it { expect(two_on_110.position_between(cd1, cd2)).
              to eq(position_110_front) }
            it { expect(two_on_110.position_between(cd2, cd1)).
              to eq(position_110_cross) }
          end
        end

        describe 'methyl_on_bridge' do
          it { expect(methyl_on_bridge_base.position_between(
              methyl_on_bridge_base.atom(:cl),
              methyl_on_bridge_base.atom(:cr))).to eq(position_100_front) }

          it { expect(methyl_on_bridge_base.position_between(
              methyl_on_bridge_base.atom(:cr),
              methyl_on_bridge_base.atom(:cl))).to eq(position_100_front) }

          it { expect(methyl_on_bridge_base.position_between(
              methyl_on_bridge_base.atom(:cm),
              methyl_on_bridge_base.atom(:cb))).to be_nil }
        end
      end
    end

  end
end
