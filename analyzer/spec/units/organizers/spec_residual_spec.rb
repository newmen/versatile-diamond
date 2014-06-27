require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe SpecResidual, type: :organizer do
      let(:methyl_on_bridge_part) { dept_methyl_on_bridge_base - dept_bridge_base }
      let(:high_bridge_part) { dept_high_bridge_base - dept_bridge_base }
      let(:big_dimer_part) { dept_dimer_base - dept_bridge_base }
      let(:small_dimer_part) { big_dimer_part - dept_bridge_base }

      it_behaves_like :minuend do
        subject { methyl_on_bridge_part }
      end

      describe '#self.empty' do
        it { expect(described_class.empty.links).to be_empty }
      end

      describe '#same?' do
        describe 'methyl_on_bridge_dup' do
          let(:another_mob_part) { dept_methyl_on_bridge_base_dup - dept_bridge_base }

          it { expect(methyl_on_bridge_part.same?(another_mob_part)).to be_truthy }

          it { expect(methyl_on_bridge_part.same?(big_dimer_part)).to be_falsey }
          it { expect(methyl_on_bridge_part.same?(high_bridge_part)).to be_falsey }
        end

        describe 'rests of (dimer - bridge), (methyl_on_dimer - methyl_on_bridge)' do
          let(:big_mod_part) { dept_methyl_on_dimer_base - dept_methyl_on_bridge_base }

          it { expect(big_dimer_part.same?(big_mod_part)).to be_falsey }
          it { expect(big_mod_part.same?(big_dimer_part)).to be_falsey }
        end
      end

      describe '#empty?' do
        it { expect(described_class.empty.empty?).to be_truthy }

        describe 'extended bridge without three bridges' do
          let(:eb) { dept_extended_bridge_base }
          subject { eb - dept_bridge_base - dept_bridge_base - dept_bridge_base }
          it { expect(subject.empty?).to be_falsey }
        end
      end

      describe '# - ' do
        it { expect(small_dimer_part.atoms_num).to eq(2) }

        it_behaves_like :count_atoms_and_references do
          subject { big_dimer_part }
          let(:atoms_num) { 4 }
          let(:relations_num) { 14 }
        end

        it_behaves_like :count_atoms_and_references do
          subject { small_dimer_part }
          let(:atoms_num) { 2 }
          let(:relations_num) { 6 }
        end

        it_behaves_like :count_atoms_and_references do
          let(:small_spec1) { dept_methyl_on_bridge_base }
          let(:small_spec2) { dept_bridge_base_dup }
          let(:big_spec) { dept_methyl_on_dimer_base }
          subject { big_spec - small_spec1 - small_spec2 }

          let(:atoms_num) { 2 }
          let(:relations_num) { 7 }
        end

        it_behaves_like :count_atoms_and_references do
          let(:eb) { dept_extended_bridge_base }
          subject { eb - dept_bridge_base - dept_bridge_base - dept_bridge_base }

          let(:atoms_num) { 2 }
          let(:relations_num) { 8 }
        end

        it_behaves_like :count_atoms_and_references do
          let(:tbs) { dept_three_bridges_base }
          subject { tbs - dept_bridge_base - dept_bridge_base - dept_bridge_base }

          let(:atoms_num) { 2 }
          let(:relations_num) { 10 }
        end
      end

      it_behaves_like :relations_of do
        subject { dept_methyl_on_dimer_base }
        let(:atom) { methyl_on_dimer_base.atom(:cr) }
        let(:rls) do
          [bond_100_front, bond_110_cross, bond_110_cross, free_bond]
        end
      end
    end

  end
end
