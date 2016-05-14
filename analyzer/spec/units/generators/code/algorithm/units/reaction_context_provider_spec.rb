require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe ReactionContextProvider, type: :algorithm do
          subject { described_class.new(dict, backbone.big_graph, ordered_graph) }

          describe '#bone_nodes' do
            describe 'just one node' do
              include_context :methyl_adsorbtion_context
              it { expect(subject.bone_nodes).to eq(entry_nodes) }
            end

            describe 'many nodes' do
              include_context :sierpinski_formation_context
              let(:all_nodes) { entry_nodes + nbr_nodes + amorph_nodes }
              it { expect(subject.bone_nodes).to match_array(all_nodes) }
            end
          end

          describe '#species_nodes' do
            include_context :sierpinski_formation_context

            describe 'anchor specie' do
              let(:nodes) { subject.species_nodes([node_specie]) }
              it { expect(nodes).to match_array(entry_nodes) }
            end

            describe 'other specie' do
              let(:nodes) { subject.species_nodes([nbr_nodes.first.uniq_specie]) }
              it { expect(nodes).to match_array(nbr_nodes + amorph_nodes) }
            end
          end

          describe '#many_times_reachable_nodes' do
            include_context :sierpinski_formation_context
            it { expect(subject.many_times_reachable_nodes(nbr_species)).to be_empty }
          end

          describe '#existed_relations_to' do
            before { dict.make_atom_s([cbr, cbl, cdr, cdl]) }
            let(:nodes) { subject.existed_relations_to(nbr_nodes, nbr_nodes) }

            describe 'side nodes with another specie are related' do
              include_context :intermed_migr_df_formation_context
              it { expect(nodes).to eq(nbr_nodes) }
            end

            describe 'side nodes with not existed relation' do
              include_context :intermed_migr_dh_formation_context
              it { expect(nodes_atoms).to eq([cdr]) }
            end
          end

          describe '#not_existed_relations_to' do
            before { dict.make_atom_s([cbr, cbl, cdr, cdl]) }
            let(:nodes) { subject.not_existed_relations_to(nbr_nodes, nbr_nodes) }

            describe 'side nodes with another specie are related' do
              include_context :intermed_migr_df_formation_context
              it { expect(nodes).to be_empty }
            end

            describe 'side nodes with not existed relation' do
              include_context :intermed_migr_dh_formation_context
              it { expect(nodes_atoms).to eq([cdl]) }
            end
          end

          describe '#private_relations_with' do
            before { dict.make_specie_s(nbr_nodes.first.uniq_specie) }

            describe 'no private relations' do
              include_context :dimer_formation_context
              before { dict.make_specie_s(node_specie) }
              it { expect(subject.private_relations_with(entry_nodes)).to be_empty }
            end

            describe 'with private relations' do
              include_context :two_next_dimers_formation_context
              before { dict.make_specie_s(bone_dimer_nodes.first.uniq_specie) }
              let(:pairs) { subject.private_relations_with(bone_dimer_nodes) }
              let(:atoms) { pairs.flat_map { |ns| ns.map(&:atom) } }
              it { expect(atoms).to match_array([cbt, cdr]) }
            end
          end

          describe '#relation_between' do
            include_context :sierpinski_formation_context
            let(:checking_nodes) { [entry_nodes.first, nbr_nodes.first] }
            let(:relation) { subject.relation_between(*checking_nodes) }
            it { expect(relation).to eq(position_100_cross) }
          end

          describe '#symmetric_close_nodes' do
            describe 'mono reactant' do
              let(:nodes) { subject.symmetric_close_nodes([node_specie]) }

              describe 'just one node' do
                include_context :methyl_adsorbtion_context
                it { expect(nodes).to be_empty }
              end

              describe 'just self nodes' do
                include_context :sierpinski_drop_context
                it { expect(nodes).to be_empty }
              end
            end

            describe 'many reactants' do
              let(:nodes) { subject.symmetric_close_nodes([nbr_specie]) }
              let(:nbr_specie) { nbr_nodes.first.uniq_specie }

              describe 'close non symmetric intermediate nodes' do
                include_context :intermed_migr_df_formation_context
                it { expect(nodes).to be_empty }
              end

              describe 'close symmetric intermediate nodes' do
                include_context :alt_intermed_migr_df_formation_context
                it 'check nodes' do
                  expect(nodes_species).to eq([nbr_specie] * 2)
                  expect(nodes_atoms).to eq([cbr, cbl])
                end
              end
            end
          end

          describe '#symmetric_relations?' do
            describe 'just one node' do
              include_context :methyl_adsorbtion_context
              it { expect(subject.symmetric_relations?(entry_nodes)).to be_falsey }
            end

            describe 'two nodes to one amorph (without bone relations)' do
              include_context :sierpinski_drop_context
              it { expect(subject.symmetric_relations?(lattice_nodes)).to be_falsey }
            end

            describe 'two nodes to one crystal (with bone relations)' do
              include_context :alt_intermed_migr_df_formation_context
              it { expect(subject.symmetric_relations?(nbr_nodes)).to be_truthy }
            end
          end

          describe '#related_from_other_defined?' do
            let(:result) { subject.related_from_other_defined?(nbr_nodes, nbr_nodes) }

            describe 'key nodes are not related' do
              include_context :sierpinski_drop_context
              before { dict.make_atom_s(lattice_nodes.map(&:atom)) }
              let(:result) do
                subject.related_from_other_defined?(amorph_nodes, amorph_nodes)
              end
              it { expect(result).to be_falsey }
            end

            describe 'side nodes with not defined self' do
              include_context :intermed_migr_df_formation_context
              before { dict.make_atom_s(nbr_atoms) }
              it { expect(result).to be_falsey }
            end

            describe 'side nodes with not defined side' do
              include_context :intermed_migr_df_formation_context
              before { dict.make_atom_s(entry_atoms) }
              it { expect(result).to be_falsey }
            end

            describe 'forward side nodes with not existed relation' do
              include_context :intermed_migr_df_formation_context
              before do
                dict.make_atom_s(entry_atoms)
                dict.make_atom_s(nbr_atoms)
              end
              it { expect(result).to be_truthy }
            end

            describe 'reverse side nodes with not existed relation' do
              include_context :intermed_migr_dh_formation_context
              before do
                dict.make_atom_s(entry_atoms)
                dict.make_atom_s(nbr_atoms)
              end
              it { expect(result).to be_truthy }
            end
          end

          describe '#key?' do
            include_context :sierpinski_drop_context
            it { expect(subject.key?(entry_nodes)).to be_truthy }
            it { expect(subject.key?(amorph_nodes)).to be_falsey }
            it { expect(subject.key?(lattice_nodes)).to be_falsey }
          end

          describe '#relations_from?' do
            shared_examples_for :check_relations_from do
              it { expect(subject.relations_from?(entry_nodes)).to eq(result) }
            end

            it_behaves_like :check_relations_from do
              include_context :methyl_adsorbtion_context
              let(:result) { false }
            end

            it_behaves_like :check_relations_from do
              include_context :dimer_formation_context
              let(:result) { true }
            end

            it_behaves_like :check_relations_from do
              include_context :sierpinski_formation_context
              let(:result) { true }
            end
          end

          describe '#cutten_bone_relations_from?' do
            let(:result) do
              subject.cutten_bone_relations_from?(cutting_nodes, target_nodes)
            end

            describe 'no relations' do
              include_context :intermed_migr_df_formation_context
              let(:cutting_nodes) { entry_nodes }
              let(:target_nodes) { nbr_nodes }
              it { expect(result).to be_falsey }
            end

            describe 'relations exists' do
              include_context :intermed_migr_df_formation_context
              let(:cutting_nodes) { nbr_nodes }
              let(:target_nodes) { entry_nodes }
              it { expect(result).to be_truthy }
            end
          end

          describe '#just_existed_bone_relations?' do
            include_context :intermed_migr_dh_formation_context

            shared_examples_for :check_existed_bone_relations do
              let(:ns) do
                atoms.map do |atom|
                  nodes.find { |n| n.atom == atom }
                end
              end

              it { expect(subject.just_existed_bone_relations?(ns[0])).to be_falsey }
              it { expect(subject.just_existed_bone_relations?(ns[1])).to be_truthy }
            end

            it_behaves_like :check_existed_bone_relations do
              let(:nodes) { entry_nodes }
              let(:atoms) { [cbl, cbr] }
            end

            it_behaves_like :check_existed_bone_relations do
              let(:nodes) { nbr_nodes }
              let(:atoms) { [cdl, cdr] }
            end
          end
        end

      end
    end
  end
end
