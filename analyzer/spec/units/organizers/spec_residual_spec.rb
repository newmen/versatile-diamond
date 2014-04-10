require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe SpecResidual do
      def wrap(base_spec)
        DependentBaseSpec.new(base_spec)
      end

      let(:wrapped_bridge) { wrap(bridge_base) }
      let(:methyl_on_bridge_part) do
        wrap(methyl_on_bridge_base).residual(wrapped_bridge)
      end
      let(:high_bridge_part) { wrap(high_bridge_base).residual(wrapped_bridge) }
      let(:big_dimer_part) { wrap(dimer_base).residual(wrapped_bridge) }
      let(:small_dimer_part) { big_dimer_part.residual(wrapped_bridge) }

      it_behaves_like :minuend do
        subject { methyl_on_bridge_part }
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

        let(:another_mob_part) do
          wrap(methyl_on_bridge_dup).residual(wrap(bridge_base_dup))
        end

        it { expect(methyl_on_bridge_part.same?(another_mob_part)).to be_true }

        it { expect(methyl_on_bridge_part.same?(big_dimer_part)).to be_false }
        it { expect(methyl_on_bridge_part.same?(high_bridge_part)).to be_false }
      end

      describe '#empty?' do
        subject { described_class.new({}) }
        it { should be_true }
      end

      describe '#residual' do
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
      end
    end

  end
end
