require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe SpecResidual do
      def wrap(base_spec)
        DependentBaseSpec.new(base_spec)
      end

      let(:wrapped_bridge) { wrap(bridge_base) }
      let(:methyl_on_bridge_part) { wrap(methyl_on_bridge_base) - wrapped_bridge }
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
        let(:methyl_on_bridge_dup) do
          m = c.dup
          b, l, r = cd.dup, cd.dup, cd.dup
          s = Concepts::SurfaceSpec.new(:mob_dup, m: m, b: b, l: l, r: r)
          s.link(m, b, free_bond)
          s.link(b, l, bond_110_cross)
          s.link(b, r, bond_110_cross); s
        end

        let(:another_mob_part) { wrap(methyl_on_bridge_dup) - wrap(bridge_base_dup) }

        it { expect(methyl_on_bridge_part.same?(another_mob_part)).to be_true }

        it { expect(methyl_on_bridge_part.same?(big_dimer_part)).to be_false }
        it { expect(methyl_on_bridge_part.same?(high_bridge_part)).to be_false }
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
        it { expect(small_dimer_part.links_size).to eq(2) }

        it_behaves_like :swap_to_atom_reference do
          subject { big_dimer_part }
          let(:atoms_num) { 1 }
          let(:refs_num) { 3 }
        end

        it_behaves_like :swap_to_atom_reference do
          subject { small_dimer_part }
          let(:atoms_num) { 0 }
          let(:refs_num) { 2 }
        end

        describe 'complex difference' do
          let(:small_spec1) { DependentBaseSpec.new(methyl_on_bridge_base) }
          let(:small_spec2) { DependentBaseSpec.new(bridge_base_dup) }
          let(:big_spec) { DependentBaseSpec.new(methyl_on_dimer_base) }
          subject { big_spec - small_spec1 - small_spec2 }

          it { expect(subject.links.size).to eq(2) }
          it { expect(subject.links.values.map(&:last).map(&:last)).
            to eq([bond_100_front] * 2) }
        end
      end
    end

  end
end
