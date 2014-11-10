require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ReactionGroupedNodes, type: :algorithm do
          let(:generator) { stub_generator(typical_reactions: [subject]) }
          let(:reaction) { generator.reaction_class(subject.name) }
          let(:grouped_nodes) { described_class.new(generator, reaction) }

          let(:big_links_method) { :original_links }
          def node_to_vertex(node); [node.uniq_specie.spec.spec, node.atom] end

          describe 'without relations' do
            let(:flatten_face_grouped_atoms) { [] }
            let(:nodes_list) { [] }
            let(:grouped_graph) { {} }

            it_behaves_like :check_grouped_nodes_graph do
              subject { dept_methyl_activation }
            end

            it_behaves_like :check_grouped_nodes_graph do
              subject { dept_methyl_desorption }
            end

            it_behaves_like :check_grouped_nodes_graph do
              subject { dept_sierpinski_drop }
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
