require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe SpecieContext, type: :algorithm do
          include_context :specie_instance_context
          include_context :raw_unique_parent_context

          let(:backbone) { Algorithm::SpecieBackbone.new(generator, original_specie) }
          let(:entry_nodes) { backbone.entry_nodes.first }
          let(:ordered_graph) { backbone.ordered_graph_from(entry_nodes) }

          let(:dict) { Expressions::VarsDictionary.new }
          let(:original_specie) { generator.specie_class(dept_uniq_specie.name) }
          subject { described_class.new(dict, original_specie, ordered_graph) }

          shared_context :rab_context do
            let(:base_specs) { [dept_bridge_base] }
            let(:specific_specs) { [dept_uniq_specie] }

            let(:dept_uniq_specie) { dept_right_hydrogenated_bridge }
            let(:node_specie) { entry_nodes.first.uniq_specie }
          end

          shared_context :two_mobs_context do
            let(:base_specs) { [dept_bridge_base, dept_uniq_specie] }
            let(:typical_reactions) { [dept_sierpinski_drop] }

            let(:dept_uniq_specie) { dept_cross_bridge_on_bridges_base }
            let(:cbs_relation) { ordered_graph.last }
            let(:node_specie) { cbs_relation.first.first.uniq_specie }
            let(:nbr_specie) { cbs_relation.last.first.first.first.uniq_specie }

            let(:scope_inst) { entry_nodes.first.uniq_specie }
            let(:none_mob) { scope_inst.species.first }
          end

          shared_context :intermed_context do
            let(:base_specs) do
              [
                dept_bridge_base,
                dept_methyl_on_bridge_base,
                dept_methyl_on_dimer_base,
                dept_uniq_specie
              ]
            end
            let(:typical_reactions) { [dept_intermed_migr_dc_drop] }

            let(:entry_nodes) do
              backbone.entry_nodes.reject { |ns| ns.first.atom.lattice }.first
            end
            let(:dept_uniq_specie) { dept_intermed_migr_down_common_base }
            let(:node_specie) { entry_nodes.first.uniq_specie }
          end

          describe '#atom_nodes' do
            describe 'without scope species' do
              include_context :rab_context
              it { expect(subject.atom_nodes([ct]).map(&:atom)).to be_empty }
              it { expect(subject.atom_nodes([cr]).map(&:atom)).to eq([cr]) }
            end

            describe 'with scope species' do
              include_context :two_mobs_context
              it { expect(subject.atom_nodes([cm]).size).to eq(1) }
              it { expect(subject.atom_nodes([cm]).map(&:atom)).to eq([cm]) }
              it { expect(subject.atom_nodes([ctl]).map(&:atom)).to eq([ctl]) }
              it { expect(subject.atom_nodes([ctr]).map(&:atom)).to eq([ctr]) }
            end
          end

          describe '#specie_nodes' do
            describe 'without scope species' do
              include_context :rab_context
              let(:nodes) { subject.specie_nodes(node_specie) }
              it { expect(nodes.map(&:uniq_specie)).to eq([node_specie]) }
              it { expect(subject.specie_nodes(uniq_parent_inst)).to be_empty } # fake
            end

            describe 'with scope species' do
              include_context :two_mobs_context
              let(:nodes) { subject.specie_nodes(scope_inst) }
              it { expect(nodes.map(&:uniq_specie)).to eq([none_mob]) }
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
                it { expect(nodes.map(&:uniq_specie)).to be_empty }
              end
            end

            describe 'with scope species' do
              include_context :two_mobs_context
              let(:nodes) { subject.reachable_nodes_with([scope_inst]) }
              it { expect(nodes.map(&:uniq_specie)).to eq([none_mob]) }
            end
          end

          describe '#symmetric_close_nodes' do
            let(:nodes) { subject.symmetric_close_nodes([node_specie]).flatten }

            describe 'just one node' do
              include_context :rab_context
              it { expect(nodes.map(&:uniq_specie)).to be_empty }
            end

            describe 'just self nodes' do
              include_context :two_mobs_context
              it { expect(nodes.map(&:uniq_specie)).to be_empty }
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
              let(:nodes) { subject.atom_nodes([ctr, ctl]) }
              it { expect(subject.symmetric_relations?(nodes)).to be_truthy }
            end
          end
        end

      end
    end
  end
end
