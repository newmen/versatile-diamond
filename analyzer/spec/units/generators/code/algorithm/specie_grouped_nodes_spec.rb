require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe SpecieGroupedNodes, type: :algorithm do
          let(:base_specs) { [] }
          let(:specific_specs) { [] }
          let(:generator) do
            stub_generator(base_specs: base_specs, specific_specs: specific_specs)
          end

          let(:specie) { generator.specie_class(subject.name) }
          let(:grouped_nodes) { described_class.new(generator, specie) }

          describe 'graphs' do
            [
              :ct, :cr, :cl, :cb, :cm, :cc, :c1, :c2, :ctl, :ctr, :csl, :csr
            ].each do |keyname|
              let(keyname) { subject.spec.atom(keyname) }
            end

            shared_examples_for :check_graph do
              # each method should not change the state of grouped nodes graph
              it 'all public methods' do
                anchor_nodes = grouped_nodes.face_grouped_nodes
                anchors = anchor_nodes.map { |ns| ns.map(&:atom) }
                expect(anchors).to match_multidim_array(face_grouped_anchors)

                typed_nodes = typed_nodes_list(grouped_nodes.final_graph)
                expect(typed_nodes).to match_array(nodes_list)

                atomic_graph = translate_to_atomic_graph(grouped_nodes.final_graph)
                expect(atomic_graph).to match_graph(grouped_graph)
              end
            end

            it_behaves_like :check_graph do
              subject { dept_bridge_base }
              let(:base_specs) { [subject] }
              let(:face_grouped_anchors) { [[ct], [cr], [cl]] }
              let(:nodes_list) do
                [
                  [NoneSpecie, ct],
                  [NoneSpecie, cr],
                  [NoneSpecie, cl]
                ]
              end
              let(:grouped_graph) do
                {
                  [ct] => [[[cl, cr], param_110_cross]],
                  [cr] => [[[ct], param_110_front]],
                  [cl] => [[[ct], param_110_front]]
                }
              end
            end

            describe 'like methyl on bridge' do
              let(:face_grouped_anchors) { [[cb], [cm]] }
              let(:nodes_list) do
                [
                  [NoneSpecie, cm],
                  [UniqueSpecie, cb]
                ]
              end
              let(:grouped_graph) do
                {
                  [cm] => [[[cb], param_amorph]],
                  [cb] => [[[cm], param_amorph]]
                }
              end

              it_behaves_like :check_graph do
                subject { dept_methyl_on_bridge_base }
                let(:base_specs) { [dept_bridge_base, subject] }
              end

              it_behaves_like :check_graph do
                subject { dept_high_bridge_base }
                let(:base_specs) { [dept_bridge_base, subject] }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_vinyl_on_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:face_grouped_anchors) { [[cb], [c1], [c2]] }
              let(:nodes_list) do
                [
                  [NoneSpecie, c1],
                  [NoneSpecie, c2],
                  [UniqueSpecie, cb]
                ]
              end
              let(:grouped_graph) do
                {
                  [cb] => [[[c1], param_amorph]],
                  [c1] => [[[cb], param_amorph], [[c2], param_amorph]],
                  [c2] => [[[c1], param_amorph]]
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_dimer_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:face_grouped_anchors) { [[cr, cl]] }
              let(:nodes_list) do
                [
                  [UniqueSpecie, cr],
                  [UniqueSpecie, cl]
                ]
              end
              let(:grouped_graph) do
                {
                  [cr] => [[[cl], param_100_front]],
                  [cl] => [[[cr], param_100_front]]
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_two_methyls_on_dimer_base }
              let(:base_specs) { [dept_dimer_base, subject] }
              let(:face_grouped_anchors) { [[cr, cl], [c1], [c2]] }
              let(:nodes_list) do
                [
                  [NoneSpecie, c1],
                  [NoneSpecie, c2],
                  [UniqueSpecie, cr],
                  [UniqueSpecie, cl]
                ]
              end
              let(:grouped_graph) do
                {
                  [c1] => [[[cr], param_amorph]],
                  [c2] => [[[cl], param_amorph]],
                  [cr] => [[[c1], param_amorph]],
                  [cl] => [[[c2], param_amorph]]
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_activated_methyl_on_incoherent_bridge }
              let(:base_specs) { [dept_methyl_on_bridge_base] }
              let(:specific_specs) { [subject] }
              let(:face_grouped_anchors) { [[cb], [cm]] }
              let(:nodes_list) do
                [
                  [UniqueSpecie, cm],
                  [UniqueSpecie, cb]
                ]
              end
              let(:grouped_graph) do
                {
                  [cb] => [],
                  [cm] => []
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_methyl_on_dimer_base }
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:face_grouped_anchors) { [[cr, cl]] }
              let(:nodes_list) do
                [
                  [UniqueSpecie, cr],
                  [UniqueSpecie, cl]
                ]
              end
              let(:grouped_graph) do
                {
                  [cr] => [[[cl], param_100_front]],
                  [cl] => [[[cr], param_100_front]]
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_three_bridges_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:face_grouped_anchors) { [[ct], [cc]] }
              let(:nodes_list) do
                [
                  [SpeciesScope, ct],
                  [SpeciesScope, cc]
                ]
              end
              let(:grouped_graph) do
                {
                  [ct] => [],
                  [cc] => []
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_right_hydrogenated_bridge }
              let(:base_specs) { [dept_bridge_base] }
              let(:specific_specs) { [subject] }
              let(:face_grouped_anchors) { [[cr]] }
              let(:nodes_list) do
                [
                  [UniqueSpecie, cr]
                ]
              end
              let(:grouped_graph) do
                {
                  [cr] => []
                }
              end
            end

            describe 'different dept_cross_bridge_on_bridges_base' do
              subject { dept_cross_bridge_on_bridges_base }
              let(:face_grouped_anchors) { [[ctl, ctr], [cm]] }

              it_behaves_like :check_graph do
                let(:base_specs) { [dept_bridge_base, subject] }
                let(:nodes_list) do
                  [
                    [NoneSpecie, cm],
                    [UniqueSpecie, ctr],
                    [UniqueSpecie, ctl]
                  ]
                end
                let(:grouped_graph) do
                  {
                    [cm] => [[[ctr, ctl], param_amorph]],
                    [ctr] => [[[ctl], param_100_cross], [[cm], param_amorph]],
                    [ctl] => [[[ctr], param_100_cross], [[cm], param_amorph]]
                  }
                end
              end

              it_behaves_like :check_graph do
                let(:base_specs) do
                  [dept_bridge_base, dept_methyl_on_bridge_base, subject]
                end
                let(:nodes_list) do
                  [
                    [SpeciesScope, cm],
                    [UniqueSpecie, ctr],
                    [UniqueSpecie, ctl]
                  ]
                end
                let(:grouped_graph) do
                  {
                    [cm] => [],
                    [ctr] => [[[ctl], param_100_cross]],
                    [ctl] => [[[ctr], param_100_cross]]
                  }
                end
              end
            end

            describe 'different dept_cross_bridge_on_dimers_base' do
              subject { dept_cross_bridge_on_dimers_base }
              let(:face_grouped_anchors) { [[ctr, csr], [ctl, csl], [cm]] }

              it_behaves_like :check_graph do
                let(:base_specs) { [dept_dimer_base, subject] }
                let(:nodes_list) do
                  [
                    [NoneSpecie, cm],
                    [UniqueSpecie, ctr],
                    [UniqueSpecie, csr],
                    [UniqueSpecie, ctl],
                    [UniqueSpecie, csl]
                  ]
                end
                let(:grouped_graph) do
                  {
                    [cm] => [[[ctr, ctl], param_amorph]],
                    [ctr] => [[[cm], param_amorph]],
                    [ctl] => [[[cm], param_amorph]],
                    [csr, ctr] => [[[csl, ctl], param_100_cross]],
                    [csl, ctl] => [[[csr, ctr], param_100_cross]]
                  }
                end
              end

              it_behaves_like :check_graph do
                let(:base_specs) do
                  [dept_dimer_base, dept_methyl_on_dimer_base, subject]
                end
                let(:nodes_list) do
                  [
                    [SpeciesScope, cm],
                    [UniqueSpecie, ctr],
                    [UniqueSpecie, csr],
                    [UniqueSpecie, ctl],
                    [UniqueSpecie, csl]
                  ]
                end
                let(:grouped_graph) do
                  {
                    [cm] => [],
                    [csr, ctr] => [[[csl, ctl], param_100_cross]],
                    [csl, ctl] => [[[csr, ctr], param_100_cross]]
                  }
                end
              end
            end
          end
        end

      end
    end
  end
end
