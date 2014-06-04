require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe TableCell do
      def wrap(spec)
        DependentBaseSpec.new(spec)
      end

      let(:wb) { wrap(bridge_base) }
      let(:wdm) { wrap(dimer_base) }
      let(:wmob) { wrap(methyl_on_bridge_base) }
      let(:wmodm) { wrap(methyl_on_dimer_base) }

      let(:bad_modm_part) { wmodm - wdm }
      let(:big_modm_part) { wmodm - wmob }
      let(:medium_modm_part) { wmodm - wb - wb }
      let(:small_modm_part) { big_modm_part - wb }

      let(:bad) { described_class.new(bad_modm_part, [wdm]) }
      let(:big) { described_class.new(big_modm_part, [wmob]) }
      let(:medium) { described_class.new(medium_modm_part, [wb, wb]) }
      let(:small) { described_class.new(small_modm_part, [wmob, wb]) }
      let(:smallest) { described_class.new(small_modm_part, [wb]) }

      describe '#<=>' do
        it { expect((small <=> medium) < 0).to be_truthy }
        it { expect((small <=> smallest) > 0).to be_truthy }

        it { expect((small <=> bad) < 0).to be_truthy }
      end

      describe '#adsorb' do
        subject { big.adsorb(smallest) }
        it { expect(subject.residual).to eq(small_modm_part) }
        it { expect(subject.specs).to match_array([wmob, wb]) }
      end

      describe '#empty?' do
        let(:empty_part) { SpecResidual.empty }
        let(:empty_cell) { described_class.new(empty_part) }
        let(:not_empty_cell) { described_class.new(medium) }

        it { expect(empty_cell.empty?).to be_truthy }
        it { expect(not_empty_cell.empty?).to be_falsey }
      end
    end

  end
end
