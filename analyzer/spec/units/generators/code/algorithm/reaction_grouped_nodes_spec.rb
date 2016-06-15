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
              let(:atom) { :cm }
            end

            it_behaves_like :check_grouped_nodes_graph do
              subject { dept_methyl_desorption }
              let(:atom) { :cb }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_sierpinski_drop }

            let(:flatten_face_grouped_atoms) { [[:ctl, :cm, :ctr]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, :ctl],
                [Instances::UniqueReactant, :cm],
                [Instances::UniqueReactant, :ctr]
              ]
            end
            let(:grouped_graph) do
              {
                [:ctl, :cm, :ctr] => []
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_dimer_formation }

            let(:flatten_face_grouped_atoms) { [[:ct, :ct]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, :ct],
                [Instances::UniqueReactant, :ct]
              ]
            end

            let(:ab) { :'bridge(ct: *)__ct' }
            let(:aib) { :'bridge(ct: *, ct: i)__ct' }
            let(:grouped_graph) do
              {
                [ab] => [[[aib], param_100_front]],
                [aib] => [[[ab], param_100_front]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_incoherent_dimer_drop }

            let(:flatten_face_grouped_atoms) { [[:cr, :cl]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, :cr],
                [Instances::UniqueReactant, :cl]
              ]
            end
            let(:grouped_graph) do
              {
                [:cr, :cl] => []
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_sierpinski_formation }

            let(:flatten_face_grouped_atoms) { [[:ct, :cb]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, :ct],
                [Instances::UniqueReactant, :cb]
              ]
            end
            let(:grouped_graph) do
              {
                [:ct] => [[[:cb], param_100_cross]],
                [:cb] => [[[:ct], param_100_cross]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_intermed_migr_dc_formation }

            let(:flatten_face_grouped_atoms) { [[:cr, :cr]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, :cr],
                [Instances::UniqueReactant, :cr]
              ]
            end

            let(:modr) { :'methyl_on_dimer(cm: *)__cr' }
            let(:br) { :'bridge(ct: *)__cr' }
            let(:grouped_graph) do
              {
                [modr] => [[[br], param_100_cross]],
                [br] => [[[modr], param_100_cross]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_intermed_migr_dh_formation }

            let(:flatten_face_grouped_atoms) { [[:cr, :cl], [:cr, :cl]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, :cr],
                [Instances::UniqueReactant, :cl],
                [Instances::UniqueReactant, :cr],
                [Instances::UniqueReactant, :cl]
              ]
            end

            let(:modr) { :'methyl_on_dimer(cm: *)__cr' }
            let(:modl) { :'methyl_on_dimer(cm: *)__cl' }
            let(:br) { :'bridge(ct: *)__cr' }
            let(:bl) { :'bridge(ct: *)__cl' }
            let(:grouped_graph) do
              {
                [modr, modl] => [[[br, bl], param_100_cross]],
                [br, bl] => [[[modr, modl], param_100_cross]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_methyl_incorporation }

            let(:flatten_face_grouped_atoms) { [[:cr, :cl], [:cr, :cl]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, :cr],
                [Instances::UniqueReactant, :cl],
                [Instances::UniqueReactant, :cr],
                [Instances::UniqueReactant, :cl]
              ]
            end

            let(:dr) { :'dimer(cr: *)__cr' }
            let(:dl) { :'dimer(cr: *)__cl' }
            let(:mobr) { :'methyl_on_bridge(cm: *)__cr' }
            let(:mobl) { :'methyl_on_bridge(cm: *)__cl' }
            let(:grouped_graph) do
              {
                [dr, dl] => [[[mobl, mobr], param_100_cross]],
                [mobl, mobr] => [[[dr, dl], param_100_cross]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_methyl_to_gap }

            let(:flatten_face_grouped_atoms) { [[:cr, :cl], [:cr, :cr]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, :cl],
                [Instances::UniqueReactant, :cr],
                [Instances::UniqueReactant, :cr],
                [Instances::UniqueReactant, :cr]
              ]
            end

            let(:br0) { :'bridge(cr: *)__0__cr' }
            let(:br1) { :'bridge(cr: *)__1__cr' }
            let(:mobr) { :'methyl_on_bridge(cm: *, cm: *)__cr' }
            let(:grouped_graph) do
              {
                [br0] => [[[br1], param_100_front]],
                [br1] => [[[br0], param_100_front]],
                [br0, br1] => [[[:cl, mobr], param_100_cross]],
                [:cl, mobr] => [[[br0, br1], param_100_cross]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_two_side_dimers_formation }

            let(:flatten_face_grouped_atoms) { [[:cr, :cl], [:cr, :cl]] }
            let(:nodes_list) do
              [
                [Instances::UniqueReactant, :cr],
                [Instances::UniqueReactant, :cl],
                [Instances::UniqueReactant, :cr],
                [Instances::UniqueReactant, :cl]
              ]
            end

            let(:dl) { :'dimer(cl: *, cr: i)__cl' }
            let(:br) { :'bridge(cr: *)__cr' }
            let(:mobl) { :'methyl_on_bridge(cm: *, cm: *)__cl' }
            let(:mobr) { :'methyl_on_bridge(cm: *, cm: *)__cr' }
            let(:grouped_graph) do
              {
                [br] => [[[dl], param_100_front]],
                [dl] => [[[br], param_100_front]],
                [br, dl] => [[[mobr, mobl], param_100_cross]],
                [mobr, mobl] => [[[br, dl], param_100_cross]]
              }
            end
          end
        end

      end
    end
  end
end
