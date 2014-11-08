require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe SpeciesScope, type: :algorithm do
          subject { described_class.new(code_species) }
          let(:code_species) { [code_bridge_base, code_dimer_base] }

          describe '#species' do
            it { expect(subject.species).to eq(code_species) }
          end

          describe '#none?' do
            it { expect(subject.none?).to be_falsey }
          end

          describe '#scope?' do
            it { expect(subject.scope?).to be_truthy }
          end
        end

      end
    end
  end
end
