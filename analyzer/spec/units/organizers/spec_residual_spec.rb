require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe SpecResidual do
      def wrap(base_spec)
        DependentBaseSpec.new(base_spec)
      end

      let(:wrapped_bridge) { wrap(bridge_base) }
      let(:wrapped_mob) { wrap(methyl_on_bridge_base) }
      let(:methyl_on_bridge_part) { wrapped_mob - wrapped_bridge }
      let(:high_bridge_part) { wrap(high_bridge_base) - wrapped_bridge }
      let(:big_dimer_part) { wrap(dimer_base) - wrapped_bridge }
      let(:small_dimer_part) { big_dimer_part - wrapped_bridge }

      it_behaves_like :minuend do
        subject { methyl_on_bridge_part }
      end

      describe '#self.empty' do
        it { expect(described_class.empty.links).to be_empty }
      end

      describe '#same?' do
        describe 'methyl_on_bridge_dup' do
          let(:methyl_on_bridge_dup) do
            s = Concepts::SurfaceSpec.new(:mob_dup, m: c)
            s.adsorb(bridge_base_dup)
            s.rename_atom(:t, :b)
            s.link(s.atom(:m), s.atom(:b), free_bond); s
          end

          let(:another_mob_part) { wrap(methyl_on_bridge_dup) - wrapped_bridge }

          it { expect(methyl_on_bridge_part.same?(another_mob_part)).to be_true }

          it { expect(methyl_on_bridge_part.same?(big_dimer_part)).to be_false }
          it { expect(methyl_on_bridge_part.same?(high_bridge_part)).to be_false }
        end

        describe 'rests of (dimer - bridge), (methyl_on_dimer - methyl_on_bridge)' do
          let(:big_mod_part) { wrap(methyl_on_dimer_base) - wrapped_mob }
          it { expect(big_dimer_part.same?(big_mod_part)).to be_false }
          it { expect(big_mod_part.same?(big_dimer_part)).to be_false }
        end
      end

      describe '#empty?' do
        it { expect(described_class.empty.empty?).to be_true }

        describe 'extended bridge without three bridges' do
          let(:eb) { wrap(extended_bridge_base) }
          subject { eb - wrapped_bridge - wrapped_bridge - wrapped_bridge }
          it { expect(subject.empty?).to be_false }
        end
      end

      describe '# - ' do
        it { expect(small_dimer_part.atoms_num).to eq(2) }

        it_behaves_like :swap_to_atom_reference do
          subject { big_dimer_part }
          let(:atoms_num) { 1 }
          let(:relations_num) { 3 }
        end

        it_behaves_like :swap_to_atom_reference do
          subject { small_dimer_part }
          let(:atoms_num) { 0 }
          let(:relations_num) { 2 }
        end

        describe 'complex difference' do
          let(:small_spec1) { DependentBaseSpec.new(methyl_on_bridge_base) }
          let(:small_spec2) { DependentBaseSpec.new(bridge_base_dup) }
          let(:big_spec) { DependentBaseSpec.new(methyl_on_dimer_base) }
          subject { big_spec - small_spec1 - small_spec2 }

          it { should be_a(described_class) }
          it { expect(subject.links.size).to eq(2) }
          it { expect(subject.links.values.map(&:last).map(&:last)).
            to eq([bond_100_front] * 2) }
        end

        describe 'border extended_bridge atoms have correct relations' do
          subject { eb - wrapped_bridge - wrapped_bridge - wrapped_bridge }
          let(:eb) { wrap(extended_bridge_base) }
          let(:atoms) { subject.links.keys }
          let(:rls) do
            [bond_110_front, bond_110_cross, bond_110_cross, position_100_front]
          end

          it { expect(subject.links.size).to eq(2) }
          it 'both atoms has same relations' do
            atoms.each do |atom|
              expect(subject.relations_of(atom)).to match_array(rls)
            end
          end
        end

        describe 'border three_bridges atoms have correct relations' do
          subject { tbs - wrapped_bridge - wrapped_bridge - wrapped_bridge }
          let(:tbs) { wrap(three_bridges_base) }
          let(:atoms) { subject.links.keys }

          let(:center_rls) do
            [
              position_100_front, position_100_front,
              bond_110_front, bond_110_front,
              bond_110_cross, bond_110_cross,
            ]
          end
          let(:border_rls) do
            [bond_110_front, bond_110_cross, bond_110_cross, position_100_front]
          end

          it { expect(subject.links.size).to eq(2) }
          it { expect(subject.relations_of(atoms.first)).to match_array(center_rls) }
          it { expect(subject.relations_of(atoms.last)).to match_array(border_rls) }
        end
      end

      it_behaves_like :relations_of do
        let(:spec) { methyl_on_dimer_base }
        let(:atom) { spec.atom(:cr) }
        let(:rls) do
          [bond_100_front, bond_110_cross, bond_110_cross, free_bond]
        end
      end
    end

  end
end
