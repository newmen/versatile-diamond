require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentBaseSpec do
      def wrap(spec)
        described_class.new(spec)
      end

      let(:specs) do
        [
          bridge_base,
          dimer_base,
          high_bridge_base,
          methyl_on_bridge_base,
          methyl_on_dimer_base,
          extended_bridge_base,
          extended_dimer_base,
          methyl_on_extended_bridge_base,
        ]
      end

      let(:cache) { Hash[specs.map { |spec| [spec.name, wrap(spec)] }] }

      describe '#same?' do
        describe 'bridge_base' do
          let(:same_bridge) { wrap(bridge_base_dup) }
          subject { wrap(bridge_base) }

          it { expect(subject.same?(same_bridge)).to be_true }
          it { expect(same_bridge.same?(subject)).to be_true }

          it { expect(subject.same?(wrap(dimer_base))).to be_false }
        end

        describe 'methyl_on_bridge_base' do
          let(:other) { wrap(high_bridge_base) }
          subject { wrap(methyl_on_bridge_base) }

          it { expect(subject.same?(other)).to be_false }
          it { expect(other.same?(subject)).to be_false }
        end
      end

      describe '#organize_dependencies!' do
        pending 'not implemented'
        # before { methyl_on_bridge_base.organize_dependencies!([bridge_base]) }
        # it { expect(methyl_on_bridge_base.parent).to eq(bridge_base) }
      end

      describe '#remove_child' do
        pending 'deprecated'
        # before do
        #   dimer_base.store_child(dimer)
        #   dimer_base.remove_child(dimer)
        # end
        # it { expect(dimer_base.childs).to be_empty }
      end
    end

  end
end
