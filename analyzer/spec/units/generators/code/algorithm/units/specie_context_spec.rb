require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe SpecieContext, type: :algorithm do
          subject { described_class.new(dict, original_specie, ordered_graph) }

          describe '#atoms_nodes' do
            describe 'without scope species' do
              include_context :rab_context
              it { expect(subject.atoms_nodes([ct]).map(&:atom)).to be_empty }
              it { expect(subject.atoms_nodes([cr]).map(&:atom)).to eq([cr]) }
            end

            describe 'with scope species' do
              include_context :two_mobs_context
              it { expect(subject.atoms_nodes([cm]).map(&:atom)).to eq([cm, cm]) }
              it { expect(subject.atoms_nodes([ctl]).map(&:atom)).to eq([ctl]) }
              it { expect(subject.atoms_nodes([ctr]).map(&:atom)).to eq([ctr]) }
            end
          end

          describe '#species_nodes' do
            describe 'without scope species' do
              include_context :rab_context
              let(:nodes) { subject.species_nodes([node_specie]) }
              it { expect(nodes.map(&:uniq_specie)).to eq([node_specie]) }
              it { expect(subject.species_nodes([uniq_parent_inst])).to eq([]) } # fake
            end

            describe 'with scope species' do
              include_context :two_mobs_context
              let(:nodes) { subject.species_nodes([scope_specie]) }
              it { expect(nodes.map(&:uniq_specie)).to be_empty }
            end

            describe 'with one specie of scope' do
              include_context :two_mobs_context
              let(:nodes) { subject.species_nodes([node_specie]) }
              it { expect(nodes.map(&:uniq_specie)).to eq([node_specie, node_specie]) }
            end
          end

          describe '#reachable_nodes_with' do
            describe 'without scope species' do
              include_context :rab_context
              let(:nodes) { subject.reachable_nodes_with([node_specie]) }

              describe 'undefined atom' do
                it { expect(nodes.map(&:uniq_specie)).to eq([node_specie]) }
              end

              describe 'defined atom' do
                before { dict.make_atom_s(cr) }
                it { expect(nodes).to be_empty }
              end
            end

            describe 'with scope species' do
              include_context :two_mobs_context
              it { expect(subject.reachable_nodes_with([scope_specie])).to be_empty }
            end

            describe 'with one specie of scope' do
              include_context :two_mobs_context
              let(:nodes) { subject.reachable_nodes_with([node_specie]) }

              describe 'undefined atom' do
                let(:uniq_species) { [node_specie, node_specie] }
                it { expect(nodes.map(&:uniq_specie)).to eq(uniq_species) }
              end

              describe 'defined atom' do
                before { dict.make_atom_s(cm) }
                it { expect(nodes.map(&:uniq_specie)).to eq([node_specie]) }
              end
            end
          end

          describe '#reached_nodes_with' do
            describe 'without scope species' do
              include_context :rab_context
              let(:nodes) { subject.reached_nodes_with([node_specie]) }

              describe 'undefined atom' do
                it { expect(nodes).to be_empty }
              end

              describe 'defined atom' do
                before { dict.make_atom_s(cr) }
                it { expect(nodes.map(&:atom)).to eq([cr]) }
              end
            end

            describe 'with scope species' do
              include_context :two_mobs_context
              it { expect(subject.reached_nodes_with([scope_specie])).to be_empty }
            end

            describe 'with one specie of scope' do
              include_context :two_mobs_context
              let(:nodes) { subject.reached_nodes_with([node_specie]) }

              describe 'undefined atom' do
                it { expect(nodes).to be_empty }
              end

              describe 'defined atom' do
                before { dict.make_atom_s(cm) }
                it { expect(nodes.map(&:atom)).to eq([cm]) }
              end
            end
          end

          describe '#symmetric_close_nodes' do
            let(:nodes) { subject.symmetric_close_nodes([node_specie]).flatten }

            describe 'just one node' do
              include_context :rab_context
              it { expect(nodes.map(&:uniq_specie)).to eq([node_specie]) }
              it { expect(nodes.map(&:atom)).to eq([cr]) }
            end

            describe 'just self nodes' do
              include_context :two_mobs_context
              it { expect(nodes).to be_empty }
            end

            describe 'close symmetric nodes' do
              include_context :intermed_context
              it { expect(nodes.map(&:uniq_specie)).to eq([node_specie]) }
              it { expect(nodes.map(&:atom)).to eq([cbr]) }
            end
          end

          describe '#symmetric_relations?' do
            describe 'just one node' do
              include_context :rab_context
              it { expect(subject.symmetric_relations?(entry_nodes)).to be_falsey }
            end

            describe 'two nodes to one amorph' do
              include_context :two_mobs_context
              before { dict.make_atom_s(cm) }
              let(:nodes) { subject.reachable_nodes_with(uniq_parents) }
              it { expect(subject.symmetric_relations?(nodes)).to be_truthy }
            end
          end

          describe '#related_from_other_defined?' do
            let(:result) { subject.related_from_other_defined?(unit_nodes) }

            describe 'key nodes are not related' do
              include_context :two_mobs_context
              it { expect(result).to be_falsey }
            end

            describe 'side nodes with same specie are not related' do
              include_context :alt_two_mobs_context
              it { expect(result).to be_falsey }
            end

            describe 'side nodes with another specie are not related' do
              include_context :alt_intermed_context
              it { expect(result).to be_falsey }
            end

            describe 'side nodes with another specie are related' do
              include_context :alt_intermed_context
              before { dict.make_atom_s(cbr) }
              let(:cbr) { dept_uniq_specie.spec.atom(:cbr) }
              it { expect(result).to be_truthy }
            end
          end
        end

      end
    end
  end
end
