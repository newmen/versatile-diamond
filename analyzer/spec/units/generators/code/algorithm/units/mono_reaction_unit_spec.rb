require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe MonoReactionUnit, type: :algorithm do
          subject { described_class.new(dict, node) }
          let(:node) { entry_nodes.first }

          describe '#define!' do
            include_context :methyl_adsorbtion_context
            before { subject.define! }
            let(:var) { dict.var_of(node_specie) }
            it { expect(var.code).to eq('target') }
          end

          describe '#units' do
            include_context :methyl_adsorbtion_context
            it { expect(subject.units).to eq([subject]) }
          end

          describe '#filled_inner_units' do
            include_context :methyl_adsorbtion_context

            describe 'predefined specie' do
              before { subject.define! }
              it { expect(subject.filled_inner_units).to eq([subject]) }
            end

            describe 'specie is not defined' do
              it { expect(subject.filled_inner_units).to be_empty }
            end
          end

          describe '#checkable?' do
            include_context :methyl_adsorbtion_context

            describe 'undefined species' do
              it { expect(subject.checkable?).to be_truthy }
            end

            describe 'all species are defined' do
              before { dict.make_specie_s(node_specie) }
              it { expect(subject.checkable?).to be_falsey }
            end
          end

          describe '#neighbour?' do
            include_context :dimer_formation_context
            let(:nbr_unit) { described_class.new(dict, nbr_nodes.first) }
            it { expect(subject.neighbour?(nbr_unit)).to be_truthy }
          end

          describe '#partially_symmetric?' do
            describe 'unsymmetric reactant' do
              include_context :methyl_adsorbtion_context
              it { expect(subject.partially_symmetric?).to be_falsey }
            end

            describe 'not partially symmetric reactant' do
              include_context :sierpinski_drop_context
              it { expect(subject.partially_symmetric?).to be_falsey }
            end
          end
        end

      end
    end
  end
end
