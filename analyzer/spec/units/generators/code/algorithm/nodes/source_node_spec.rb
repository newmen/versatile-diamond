require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        describe SourceNode, type: :algorithm do
          include_context :methyl_adsorbtion_context

          let(:factory) { Algorithm::ChangesNodesFactory.new(generator) }
          let(:gas_change) do
            typical_reaction.changes.find { |(s, _), _| s.gas? }
          end

          shared_context :with_gas do
            subject { factory.source_node(*gas_change) }
          end

          shared_context :without_gas do
            subject { factory.source_node(*surface_change) }
            let(:surface_change) { (typical_reaction.changes.to_a - gas_change).first }
          end

          describe '#product' do
            include_context :with_gas
            it { expect(subject.product.gas?).to be_falsey }
            it { expect(subject.product).to equal(subject.product) }
            it { expect(subject.product.source).to equal(subject) }
            it { expect(subject.product.source.product).to equal(subject.product) }
          end

          describe '#gas?' do
            describe 'gas' do
              include_context :with_gas
              it { expect(subject.gas?).to be_truthy }
            end

            describe 'surface' do
              include_context :without_gas
              it { expect(subject.gas?).to be_falsey }
            end
          end

          describe '#switch?' do
            describe 'gas' do
              include_context :with_gas
              it { expect(subject.switch?).to be_truthy }
            end

            describe 'surface' do
              include_context :without_gas
              it { expect(subject.switch?).to be_falsey }
            end
          end

          describe '#transit?' do
            describe 'gas' do
              include_context :with_gas
              it { expect(subject.transit?).to be_falsey }
            end

            describe 'surface' do
              include_context :without_gas
              it { expect(subject.transit?).to be_falsey }
            end
          end

          describe '#different?' do
            describe 'gas' do
              include_context :with_gas
              it { expect(subject.different?).to be_truthy }
            end

            describe 'surface' do
              include_context :without_gas
              it { expect(subject.different?).to be_falsey }
            end
          end

          describe '#transitions' do
            describe 'gas' do
              include_context :with_gas
              it { expect(subject.transitions).to eq([]) }
            end

            describe 'surface' do
              include_context :without_gas
              it { expect(subject.transitions.size).to eq(3) }
            end
          end

          describe '#wrong_roles' do
            describe 'gas' do
              include_context :with_gas
              it { expect(subject.wrong_roles).to eq([]) }
            end

            describe 'surface' do
              include_context :without_gas
              it { expect(subject.wrong_roles.size).to eq(1) }
            end
          end
        end

      end
    end
  end
end
