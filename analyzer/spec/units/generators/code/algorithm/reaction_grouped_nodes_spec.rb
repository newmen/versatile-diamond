
require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ReactionGroupedNodes, type: :algorithm do
          let(:generator) { stub_generator(typical_reactions: [subject]) }
          let(:reaction) { generator.reaction_class(subject.name) }
          let(:grouped_nodes) { described_class.new(generator, reaction) }

          let(:big_links_method) { :links }
          def node_to_vertex(node); [node.uniq_specie.spec.spec, node.atom] end

          describe 'without positions && just one atom' do
            let(:flatten_face_grouped_atoms) { [[atom]] }
            let(:nodes_list) { [[UniqueSpecie, atom]] }
            let(:grouped_graph) { { [atom] => [] } }

            it_behaves_like :check_grouped_nodes_graph do
              subject { dept_methyl_activation }
              let(:atom) { methyl_on_bridge_base.atom(:cm) }
            end

            it_behaves_like :check_grouped_nodes_graph do
              subject { dept_methyl_desorption }
              let(:atom) { methyl_on_bridge_base.atom(:cb) }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_sierpinski_drop }
            let(:a1) { cross_bridge_on_bridges_base.atom(:ctl) }
            let(:a2) { cross_bridge_on_bridges_base.atom(:ctr) }
            let(:a3) { cross_bridge_on_bridges_base.atom(:cm) }

            let(:flatten_face_grouped_atoms) { [[a1, a2], [a3]] }
            let(:nodes_list) do
              [
                [UniqueSpecie, a1],
                [UniqueSpecie, a2],
                [UniqueSpecie, a3]
              ]
            end
            let(:grouped_graph) do
              {
                [a1, a2, a3] => []
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_dimer_formation }
            let(:a1) { activated_bridge.atom(:ct) }
            let(:a2) { activated_incoherent_bridge.atom(:ct) }

            let(:flatten_face_grouped_atoms) { [[a1, a2]] }
            let(:nodes_list) do
              [
                [UniqueSpecie, a1],
                [UniqueSpecie, a2]
              ]
            end
            let(:grouped_graph) do
              {
                [a1] => [[[a2], param_100_front]],
                [a2] => [[[a1], param_100_front]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_sierpinski_formation }
            let(:a1) { activated_bridge.atom(:ct) }
            let(:a2) { activated_methyl_on_bridge.atom(:cb) }

            let(:flatten_face_grouped_atoms) { [[a1, a2]] }
            let(:nodes_list) do
              [
                [UniqueSpecie, a1],
                [UniqueSpecie, a2]
              ]
            end
            let(:grouped_graph) do
              {
                [a1] => [[[a2], param_100_cross]],
                [a2] => [[[a1], param_100_cross]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_intermed_migr_dh_formation }
            let(:ab) { activated_bridge.atom(:cr) }
            let(:ob) { activated_bridge.atom(:cl) }
            let(:ad) { activated_methyl_on_dimer.atom(:cr) }
            let(:od) { activated_methyl_on_dimer.atom(:cl) }

            let(:flatten_face_grouped_atoms) { [[ab, ad]] }
            let(:nodes_list) do
              [
                [UniqueSpecie, ab],
                [UniqueSpecie, ob],
                [UniqueSpecie, ad],
                [UniqueSpecie, od]
              ]
            end
            let(:grouped_graph) do
              {
                [ab, ob] => [[[ad, od], param_100_cross]],
                [ad, od] => [[[ab, ob], param_100_cross]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_methyl_incorporation }
            let(:am1) { activated_methyl_on_bridge.atom(:cr) }
            let(:am2) { activated_methyl_on_bridge.atom(:cl) }
            let(:ad1) { activated_dimer.atom(:cr) }
            let(:ad2) { activated_dimer.atom(:cl) }

            let(:flatten_face_grouped_atoms) { [[am1, am2], [ad1, ad2]] }
            let(:nodes_list) do
              [
                [UniqueSpecie, am1],
                [UniqueSpecie, am2],
                [UniqueSpecie, ad1],
                [UniqueSpecie, ad2]
              ]
            end
            let(:grouped_graph) do
              {
                [am1, am2] => [[[ad2, ad1], param_100_cross]],
                [ad2, ad1] => [[[am1, am2], param_100_cross]]
              }
            end
          end
        end

      end
    end
  end
end
