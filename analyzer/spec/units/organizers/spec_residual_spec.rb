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
          let(:small_spec1) { DependentBaseSpec.new(methyl_on_bridge_base) }
          let(:small_spec2) { DependentBaseSpec.new(bridge_base_dup) }
          let(:big_spec) { DependentBaseSpec.new(methyl_on_dimer_base) }
          subject { big_spec - small_spec1 - small_spec2 }

          let(:atoms_num) { 2 }
          let(:relations_num) { 7 }
        end

        it_behaves_like :count_atoms_and_references do
          let(:eb) { wrap(extended_bridge_base) }
          subject { eb - wrapped_bridge - wrapped_bridge - wrapped_bridge }

          let(:atoms_num) { 2 }
          let(:relations_num) { 8 }
        end

        it_behaves_like :count_atoms_and_references do
          let(:tbs) { wrap(three_bridges_base) }
          subject { tbs - wrapped_bridge - wrapped_bridge - wrapped_bridge }

          let(:atoms_num) { 2 }
          let(:relations_num) { 10 }
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
