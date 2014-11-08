require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ReactionGroupedNodes, type: :algorithm do
          let(:generator) { stub_generator(typical_reactions: [subject]) }
          let(:reaction) { generator.reaction_class(subject.name) }
          let(:grouped_nodes) { described_class.new(generator, reaction) }

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
            let(:a11) { activated_methyl_on_bridge.atom(:cr) }
            let(:a12) { activated_methyl_on_bridge.atom(:cl) }
            let(:a21) { activated_dimer.atom(:cr) }
            let(:a22) { activated_dimer.atom(:cl) }

            let(:flatten_face_grouped_atoms) { [[a11, a12], [a21, a22]] }
            let(:nodes_list) do
              [
                [UniqueSpecie, a11],
                [UniqueSpecie, a12],
                [UniqueSpecie, a21],
                [UniqueSpecie, a22]
              ]
            end
            let(:grouped_graph) do
              {
                [a11, a12] => [[[a21, a22], param_100_cross]],
                [a21, a22] => [[[a11, a12], param_100_cross]]
              }
            end
          end
        end

      end
    end
  end
end
