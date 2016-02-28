require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ReactionGroupedNodes, type: :algorithm do
          def node_to_vertex(node)
            node.spec_atom
          end

          let(:source) { subject.source.reject(&:gas?).reject(&:simple?) }
          let(:generator) { stub_generator(typical_reactions: [subject]) }
          let(:reaction) { generator.reaction_class(subject.name) }
          let(:grouped_nodes) { described_class.new(generator, reaction) }

          let(:big_links_method) { :links }

          describe 'without positions && just one atom' do
            let(:flatten_face_grouped_atoms) { [[atom]] }
            let(:nodes_list) { [[Instances::UniqueReactant, atom]] }
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
            let(:a1) { source.first.atom(:ctl) }
            let(:a2) { source.first.atom(:cm) }
            let(:a3) { source.first.atom(:ctr) }

            let(:flatten_face_grouped_atoms) { [[a1, a2, a3]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, a1],
                [Instances::UniqueReactant, a2],
                [Instances::UniqueReactant, a3]
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
            let(:a1) { source.first.atom(:ct) }
            let(:a2) { source.last.atom(:ct) }

            let(:flatten_face_grouped_atoms) { [[a1, a2]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, a1],
                [Instances::UniqueReactant, a2]
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
            subject { dept_incoherent_dimer_drop }
            let(:id) { source.first }
            let(:cr) { id.atom(:cr) }
            let(:cl) { id.atom(:cl) }

            let(:flatten_face_grouped_atoms) { [[cr, cl]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, cr],
                [Instances::UniqueReactant, cl]
              ]
            end
            let(:grouped_graph) do
              {
                [cr, cl] => []
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_sierpinski_formation }
            let(:a1) { source.last.atom(:ct) }
            let(:a2) { source.first.atom(:cb) }

            let(:flatten_face_grouped_atoms) { [[a1, a2]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, a1],
                [Instances::UniqueReactant, a2]
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
            subject { dept_intermed_migr_dc_formation }
            let(:abr) { source.first }
            let(:amod) { source.last }
            let(:ab) { abr.atom(:cr) }
            let(:ad) { amod.atom(:cr) }

            let(:flatten_face_grouped_atoms) { [[ab, ad]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, ab],
                [Instances::UniqueReactant, ad]
              ]
            end
            let(:grouped_graph) do
              {
                [ab] => [[[ad], param_100_cross]],
                [ad] => [[[ab], param_100_cross]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_intermed_migr_dh_formation }
            let(:abr) { source.first }
            let(:amod) { source.last }
            let(:ab) { abr.atom(:cr) }
            let(:ob) { abr.atom(:cl) }
            let(:ad) { amod.atom(:cr) }
            let(:od) { amod.atom(:cl) }

            let(:flatten_face_grouped_atoms) { [[ad, od], [ab, ob]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, ab],
                [Instances::UniqueReactant, ob],
                [Instances::UniqueReactant, ad],
                [Instances::UniqueReactant, od]
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
            let(:amob) { source.first }
            let(:ad) { source.last }
            let(:am1) { amob.atom(:cr) }
            let(:am2) { amob.atom(:cl) }
            let(:ad1) { ad.atom(:cr) }
            let(:ad2) { ad.atom(:cl) }

            let(:flatten_face_grouped_atoms) { [[am1, am2], [ad1, ad2]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, am1],
                [Instances::UniqueReactant, am2],
                [Instances::UniqueReactant, ad1],
                [Instances::UniqueReactant, ad2]
              ]
            end
            let(:grouped_graph) do
              {
                [am1, am2] => [[[ad2, ad1], param_100_cross]],
                [ad2, ad1] => [[[am1, am2], param_100_cross]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_methyl_to_gap }
            let(:amob) { source.first }
            let(:br1) { source[1] }
            let(:br2) { source[2] }
            let(:amr) { amob.atom(:cr) }
            let(:aml) { amob.atom(:cl) }
            let(:cr1) { br1.atom(:cr) }
            let(:cr2) { br2.atom(:cr) }

            let(:flatten_face_grouped_atoms) { [[aml, amr], [cr2, cr1]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, amr],
                [Instances::UniqueReactant, aml],
                [Instances::UniqueReactant, cr1],
                [Instances::UniqueReactant, cr2]
              ]
            end
            let(:grouped_graph) do
              {
                [cr1] => [[[cr2], param_100_front]],
                [cr2] => [[[cr1], param_100_front]],
                [aml, amr] => [[[cr2, cr1], param_100_cross]],
                [cr2, cr1] => [[[aml, amr], param_100_cross]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_two_dimers_form }
            let(:eamob) { source.first }
            let(:rab) { source[1] }
            let(:aid) { source[2] }
            let(:mr) { eamob.atom(:cr) }
            let(:ml) { eamob.atom(:cl) }
            let(:ba) { rab.atom(:cr) }
            let(:da) { aid.atom(:cl) }

            let(:flatten_face_grouped_atoms) { [[mr, ml], [ba, da]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, mr],
                [Instances::UniqueReactant, ml],
                [Instances::UniqueReactant, ba],
                [Instances::UniqueReactant, da]
              ]
            end
            let(:grouped_graph) do
              {
                [ba] => [[[da], param_100_front]],
                [da] => [[[ba], param_100_front]],
                [mr, ml] => [[[ba, da], param_100_cross]],
                [ba, da] => [[[mr, ml], param_100_cross]]
              }
            end
          end
        end

      end
    end
  end
end
