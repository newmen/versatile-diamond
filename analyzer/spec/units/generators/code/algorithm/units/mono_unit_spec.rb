require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe MonoUnit, type: :algorithm do
          include_context :rab_context

          let(:node) { unit_nodes.first }
          subject { described_class.new(dict, node) }

          describe '#define!' do
            before { subject.define! }
            let(:var) { dict.var_of(node_specie) }
            it { expect(var.code).to eq('parent') }
          end

          describe '#units' do
            it { expect(subject.units).to eq([subject]) }
          end

          describe '#filled_inner_units' do
            describe 'predefined specie' do
              before { subject.define! }
              it { expect(subject.filled_inner_units).to eq([subject]) }
            end

            describe 'predefined atom' do
              before { dict.make_atom_s(node.atom) }
              it { expect(subject.filled_inner_units).to eq([subject]) }
            end

            describe 'specie and atom are not defined' do
              it { expect(subject.filled_inner_units).to be_empty }
            end
          end
        end

      end
    end
  end
end
