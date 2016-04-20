require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe SpecieContext, type: :algorithm do
          subject { described_class.new(dict, backbone.big_graph, ordered_graph) }

          shared_examples_for :empty_existed_relations do
            describe 'key nodes are not related' do
              include_context :two_mobs_context
              before { dict.make_atom_s([ctl, ctr]) }
              it { expect(result).to be_empty }
            end

            describe 'side nodes with same specie are not related' do
              include_context :alt_two_mobs_context
              before { dict.make_atom_s([ctl, ctr]) }
              it { expect(result).to be_empty }
            end

            describe 'side nodes with another specie are not related' do
              include_context :alt_intermed_context
              it { expect(result).to be_empty }
            end
          end

          describe '#bone_nodes' do
            describe 'just one node' do
              include_context :rab_context
              it { expect(subject.bone_nodes).to eq(unit_nodes) }
            end

            describe 'three nodes' do
              include_context :alt_two_mobs_context
              let(:all_nodes) { entry_nodes.first.split + unit_nodes }
              it { expect(subject.bone_nodes).to match_array(all_nodes) }
            end
          end

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

          describe '#existed_relations_to' do
            let(:result) { subject.existed_relations_to(unit_nodes) }

            it_behaves_like :empty_existed_relations

            describe 'side nodes with another specie are related' do
              include_context :alt_intermed_context
              before { dict.make_atom_s([cbr, cdr]) }
              it { expect(result).to eq(unit_nodes) }
            end

            describe 'side nodes with not existed relation' do
              include_context :half_intermed_context
              before { dict.make_atom_s([cbl, cdl]) }
              it { expect(result).to be_empty }
            end
          end

          describe '#not_existed_relations_to' do
            let(:result) { subject.not_existed_relations_to(unit_nodes) }

            it_behaves_like :empty_existed_relations

            describe 'side nodes with another specie are related' do
              include_context :alt_intermed_context
              before { dict.make_atom_s([cbr, cdr]) }
              it { expect(result).to be_empty }
            end

            describe 'side nodes with not existed relation' do
              include_context :half_intermed_context
              before { dict.make_atom_s([cbl, cdl]) }
              it { expect(result).to eq([unit_nodes.max]) }
            end
          end

          describe '#private_relations_with' do
            before do
              specie_type = Expressions::ParentSpecieType[]
              dict.make_specie_s(unit_nodes.map(&:uniq_specie), type: specie_type)
            end
            let(:pairs) { subject.private_relations_with(unit_nodes) }

            describe 'no major relation (just context positions)' do
              include_context :tree_bridges_context
              it { expect(pairs).to be_empty }
            end

            describe 'no major relation (has context bond)' do
              include_context :bwd_context
              it { expect(pairs).to be_empty }
            end

            describe 'there is major relation' do
              include_context :bridged_bwd_context
              before { dict.make_specie_s(node_cl.uniq_specie) }
              let(:node_cl) do
                ordered_graph.find { |_, rels| !rels.empty? }.last.first.first.first
              end
              let(:atoms) { pairs.flat_map { |ns| ns.map(&:atom) } }
              it { expect(atoms).to match_array([ct, cl]) }
            end
          end

          describe '#relation_between' do
            let(:relation) { subject.relation_between(unit_nodes.first, nbr_node) }

            describe 'no relation' do
              include_context :intermed_context
              let(:dimer_node) { (backbone.entry_nodes - entry_nodes).first.first }
              let(:nbr_node) do
                (ordered_graph.map(&:first) - backbone.entry_nodes).first.first
              end
              it { expect(nbr_node).to be_a(Algorithm::Nodes::BaseNode) }
              it { expect(relation).to be_nil }
            end

            describe 'bond' do
              include_context :alt_intermed_context
              let(:nbr_node) { (backbone.entry_nodes - [entry_nodes]).first.first }
              it { expect(relation).to eq(free_bond) }
            end

            describe 'position' do
              include_context :alt_two_mobs_context
              let(:nbr_node) { unit_nodes.last }
              it { expect(relation).to eq(position_100_cross) }
            end
          end

          describe '#symmetric_close_nodes' do
            let(:nodes) { subject.symmetric_close_nodes([node_specie]).flatten }

            describe 'just one node with undefined atom' do
              include_context :rab_context
              it { expect(nodes).to be_empty }
            end

            describe 'just one node with defined atom' do
              include_context :rab_context
              before { dict.make_atom_s(cr) }
              it { expect(nodes).to be_empty }
            end

            describe 'just self nodes' do
              include_context :two_mobs_context
              it { expect(nodes).to be_empty }
            end

            describe 'close symmetric intermediate nodes' do
              include_context :intermed_context
              it { expect(nodes.map(&:uniq_specie)).to eq([node_specie]) }
              it { expect(nodes.map(&:atom)).to eq([cbr]) }
            end

            describe 'close atom half symmetric nodes' do
              include_context :top_mob_context
              it { expect(nodes.map(&:uniq_specie)).to eq([node_specie]) }
              it { expect(nodes.map(&:atom)).to eq([cr]) }
            end

            describe 'close atom on half-reversed non symmetric nodes' do
              include_context :alt_top_mob_context

              describe 'one specie' do
                it { expect(nodes).to be_empty }
              end

              describe 'two species' do
                let(:bridge) { node_specie }
                let(:methyl_on_bridge) { backbone.entry_nodes.first.first.uniq_specie }
                let(:nodes) do
                  subject.symmetric_close_nodes([bridge, methyl_on_bridge]).flatten
                end
                it { expect(nodes).to be_empty }
              end
            end

            describe 'close atom half-reversed symmetric nodes' do
              include_context :alt_top_mob_context

              # override to MethylOnBridge
              let(:node_specie) { backbone.entry_nodes.first.first.uniq_specie }

              shared_examples_for :check_half_reverse_symmetric_nodes do
                it { expect(nodes.map(&:uniq_specie)).to eq([node_specie]) }
                it { expect(nodes.map(&:atom)).to eq([cr]) }
              end

              it_behaves_like :check_half_reverse_symmetric_nodes

              it_behaves_like :check_half_reverse_symmetric_nodes do
                before { dict.make_atom_s(cr) }
              end

              it_behaves_like :check_half_reverse_symmetric_nodes do
                before { dict.make_atom_s(ct) }
              end

              it_behaves_like :check_half_reverse_symmetric_nodes do
                before do
                  dict.make_atom_s(ct)
                  dict.make_atom_s(cr)
                end
              end
            end
          end

          describe '#symmetric_relations?' do
            describe 'just one node' do
              include_context :rab_context
              it { expect(subject.symmetric_relations?(entry_nodes)).to be_falsey }
            end

            describe 'two nodes to one amorph (not symmetric by backbone)' do
              include_context :two_mobs_context
              before { dict.make_atom_s(cm) }
              let(:nodes) { subject.reachable_nodes_with(uniq_parents) }
              it { expect(subject.symmetric_relations?(nodes)).to be_falsey }
            end
          end

          describe '#related_from_other_defined?' do
            let(:result) { subject.related_from_other_defined?(unit_nodes) }

            describe 'key nodes are not related' do
              include_context :two_mobs_context
              before { dict.make_atom_s([ctl, ctr]) }
              it { expect(result).to be_falsey }
            end

            describe 'side nodes with same specie are not related' do
              include_context :alt_two_mobs_context
              before { dict.make_atom_s([ctl, ctr]) }
              it { expect(result).to be_falsey }
            end

            describe 'side nodes with not defined self' do
              include_context :alt_intermed_context
              before { dict.make_atom_s(cbr) }
              it { expect(result).to be_falsey }
            end

            describe 'side nodes with not defined side' do
              include_context :alt_intermed_context
              before { dict.make_atom_s(cdr) }
              it { expect(result).to be_falsey }
            end

            describe 'side nodes with another specie are related' do
              include_context :alt_intermed_context
              before do
                dict.make_atom_s(cbr)
                dict.make_atom_s(cdr)
              end
              it { expect(result).to be_truthy }
            end

            describe 'forward side nodes with not existed relation' do
              include_context :half_intermed_context
              before do
                dict.make_atom_s([cbr, cbl])
                dict.make_atom_s([cdr, cdl])
              end
              it { expect(result).to be_truthy }
            end

            describe 'reverse side nodes with not existed relation' do
              include_context :alt_half_intermed_context
              before do
                dict.make_atom_s([cbr, cbl])
                dict.make_atom_s([cdr, cdl])
              end
              it { expect(result).to be_falsey }
            end
          end
        end

      end
    end
  end
end
