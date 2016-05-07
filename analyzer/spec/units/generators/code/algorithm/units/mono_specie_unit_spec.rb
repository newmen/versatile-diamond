require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe MonoSpecieUnit, type: :algorithm do
          subject { described_class.new(dict, node) }
          let(:node) { unit_nodes.first }

          describe '#define!' do
            before { subject.define! }

            describe 'no parents' do
              include_context :bridge_context
              let(:var) { dict.var_of(ct) }
              it { expect(var.code).to eq('anchor') }
            end

            describe 'just one parent' do
              include_context :rab_context
              let(:var) { dict.var_of(node_specie) }
              it { expect(var.code).to eq('parent') }
            end

            # realy case?
            describe 'many parents' do
              include_context :two_mobs_context
              let(:var) { dict.var_of(cm) }
              it { expect(var.code).to eq('anchor') }
            end
          end

          describe '#units' do
            include_context :rab_context
            it { expect(subject.units).to eq([subject]) }
          end

          describe '#filled_inner_units' do
            include_context :rab_context

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
