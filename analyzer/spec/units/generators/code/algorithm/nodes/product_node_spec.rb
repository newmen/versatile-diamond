require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        describe ProductNode, type: :algorithm do
          include_context :methyl_adsorbtion_context

          subject { factory.product_node(*change) }
          let(:factory) { Algorithm::ChangesNodesFactory.new(generator) }
          let(:change) do
            typical_reaction.changes.find { |(s, _), _| s.gas? }
          end

          describe '#source' do
            it { expect(subject.source.gas?).to be_truthy }
            it { expect(subject.source).to equal(subject.source) }
            it { expect(subject.source.product).to equal(subject) }
            it { expect(subject.source.product.source).to equal(subject.source) }
          end

          describe '#gas?' do
            it { expect(subject.gas?).to be_falsey }
          end

          describe '#transit?' do
            it { expect(subject.transit?).to be_falsey }
          end

          describe '#switch?' do
            it { expect(subject.switch?).to be_truthy }
          end

          describe '#different?' do
            it { expect(subject.different?).to be_truthy }
          end
        end

      end
    end
  end
end
