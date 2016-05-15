require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe ManyReactionUnits, type: :algorithm do
          def nodes_to_mono_units(nodes)
            nodes.map { |node| MonoReactionUnit.new(dict, node) }
          end

          def nodes_to_many_units(nodes)
            described_class.new(dict, nodes_to_mono_units(nodes))
          end

          subject { nodes_to_many_units(entry_nodes) }

          describe '#define!' do
            include_context :intermed_migr_dh_formation_context
            before { subject.define! }
            let(:var) { dict.var_of(node_specie) }
            it { expect(var.code).to eq('target') }
          end

          describe '#units' do
            include_context :intermed_migr_dh_formation_context
            it 'inner units are mono all' do
              expect(subject.units.size).to eq(2)
              expect(subject.units.flat_map(&:nodes)).to match_array(entry_nodes)
            end
          end

          describe '#filled_inner_units' do
            include_context :intermed_migr_dh_formation_context

            describe 'predefined specie' do
              before { subject.define! }
              it 'inner units are mono all' do
                units = subject.filled_inner_units
                expect(units.size).to eq(2)
                expect(units.flat_map(&:nodes)).to match_array(entry_nodes)
              end
            end

            describe 'specie is not defined' do
              it { expect(subject.filled_inner_units).to be_empty }
            end
          end

          describe '#checkable?' do
            include_context :intermed_migr_dh_formation_context

            describe 'undefined species' do
              it { expect(subject.checkable?).to be_truthy }
            end

            describe 'all species are defined' do
              before { dict.make_specie_s(node_specie) }
              it { expect(subject.checkable?).to be_falsey }
            end
          end

          describe '#neighbour?' do
            include_context :intermed_migr_dh_formation_context
            let(:nbr_unit) { nodes_to_many_units(nbr_nodes) }
            it { expect(subject.neighbour?(nbr_unit)).to be_truthy }
          end

          describe '#partially_symmetric?' do
            include_context :intermed_migr_dh_formation_context
            it { expect(subject.partially_symmetric?).to be_falsey }
          end
        end

      end
    end
  end
end
