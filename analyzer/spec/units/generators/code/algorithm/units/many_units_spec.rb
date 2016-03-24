require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe ManyUnits, type: :algorithm do
          include_context :two_mobs_context

          let(:units) do
            unit_nodes.map { |node| MonoUnit.new(dict, node) }
          end
          subject { described_class.new(dict, units) }

          describe '#define!' do
            before { subject.define! }
            let(:var) { dict.var_of(cm) }
            it { expect(var.code).to eq('anchor') }
          end

          describe '#units' do
            it { expect(subject.units).to eq(units) }
          end

          describe '#filled_inner_units' do
            describe 'predefined atom' do
              before { subject.define! }
              it { expect(subject.filled_inner_units).to eq([subject]) }
            end

            describe 'predefined species' do
              before { dict.make_specie_s(subject.species) }
              it { expect(subject.filled_inner_units).to eq([subject]) }
            end

            describe 'just one specie is predefined' do
              before { dict.make_specie_s(subject.species.first) }
              it { expect(subject.filled_inner_units).to eq([units.first]) }
            end

            describe 'species and atom are not defined' do
              it { expect(subject.filled_inner_units).to be_empty }
            end
          end
        end

      end
    end
  end
end
