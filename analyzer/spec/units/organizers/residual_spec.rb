require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe Residual do
      def wrap(base_spec)
        DependentBaseSpec.new(base_spec)
      end

      let(:wrapped_bridge) { wrap(bridge) }
      let(:methyl_on_bridge_part) { wrap(methyl_on_bridge).residual(wrapped_bridge) }
      let(:big_dimer_part) { wrap(dimer_base).residual(wrapped_bridge) }
      let(:small_dimer_part) { big_dimer_part.residual(wrapped_bridge) }

      it_behaves_like :minuend do
        subject { methyl_on_bridge_part }
      end

      describe '#same?' do
        it { expect(methyl_on_bridge_part.same?(big_dimer_part)).to be_false }
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
