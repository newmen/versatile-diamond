require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        describe SourceNode, type: :algorithm do
          include_context :methyl_adsorbtion_context

          subject { factory.source_node(*change) }
          let(:factory) { Algorithm::ChangesNodesFactory.new(generator) }
          let(:change) do
            typical_reaction.changes.find { |(s, _), _| s.gas? }
          end

          describe '#product' do
            it { expect(subject.product.gas?).to be_falsey }
            it { expect(subject.product).to equal(subject.product) }
            it { expect(subject.product.source).to equal(subject) }
            it { expect(subject.product.source.product).to equal(subject.product) }
          end

          describe '#gas?' do
            it { expect(subject.gas?).to be_truthy }
          end
        end

      end
    end
  end
end
