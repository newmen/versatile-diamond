require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe SpecieGroupedNodes, use: :engine_generator do
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

            let(:b_ct) { bridge_base.atom(:ct) }
            let(:b_cr) { bridge_base.atom(:cr) }
            let(:d_cr) { dimer_base.atom(:cr) }
            let(:d_cl) { dimer_base.atom(:cl) }
            let(:mob_cb) { methyl_on_bridge_base.atom(:cb) }
            let(:mob_cm) { methyl_on_bridge_base.atom(:cm) }
            let(:mod_cr) { methyl_on_dimer_base.atom(:cr) }
            let(:mod_cl) { methyl_on_dimer_base.atom(:cl) }
            let(:mod_cm) { methyl_on_dimer_base.atom(:cm) }
            let(:cbobs_cm) { cross_bridge_on_bridges_base.atom(:cm) }
            let(:cbods_cm) { cross_bridge_on_dimers_base.atom(:cm) }

            shared_examples_for :check_graph do
              def typed_node(node)
                [node.first.class, node.last]
              end

              # each method should not change the state of grouped nodes graph
              it 'all public methods' do
                expect(grouped_nodes.face_grouped_anchors).
                  to match_multidim_array(face_grouped_anchors)

                typed_graph =
                  grouped_nodes.graph.each_with_object({}) do |(node, rels), acc|
                    acc[typed_node(node)] = rels.map { |n, r| [typed_node(node), r] }
                  end

                expect(typed_graph).to match_graph(graph)
              end
            end

            it_behaves_like :check_graph do
              subject { dept_bridge_base }
              let(:base_specs) { [subject] }
              let(:face_grouped_anchors) { [[ct], [cr], [cl]] }
              let(:graph) do
                {
                  [[NoneSpecie, cr]] => [[[[NoneSpecie, ct]], param_110_front]],
                  [[NoneSpecie, cl]] => [[[[NoneSpecie, ct]], param_110_front]],
                  [[NoneSpecie, ct]] => [
                    [[[NoneSpecie, cl], [NoneSpecie, cr]], param_110_cross]
                  ]
                }
              end
            end

            describe 'like methyl on bridge' do
              let(:face_grouped_anchors) { [[cb], [cm]] }
              let(:graph) do
                {
                  [[NoneSpecie, cm]] => [[[[UniqueSpecie, b_ct]], param_amorph]],
                  [[UniqueSpecie, b_ct]] => [[[[NoneSpecie, cm]], param_amorph]]
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
              let(:graph) do
                {
                  [[UniqueSpecie, b_ct]] => [[[[NoneSpecie, c1]], param_amorph]],
                  [[NoneSpecie, c2]] => [[[[NoneSpecie, c1]], param_amorph]],
                  [[NoneSpecie, c1]] => [
                    [
                      [[[UniqueSpecie, b_ct]], param_amorph],
                      [[[NoneSpecie, c2]], param_amorph]
                    ]
                  ]
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_dimer_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:face_grouped_anchors) { [[cr, cl]] }
              let(:graph) do
                {
                  [[UniqueSpecie, b_ct]] => [
                    [[[UniqueSpecie, b_ct]], param_100_front]
                  ],
                  [[UniqueSpecie, b_ct]] => [
                    [[[UniqueSpecie, b_ct]], param_100_front]
                  ]
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_two_methyls_on_dimer_base }
              let(:base_specs) { [dept_dimer_base, subject] }
              let(:face_grouped_anchors) { [[cr, cl], [c1], [c2]] }
              let(:graph) do
                {
                  [[NoneSpecie, c1]] => [[[[UniqueSpecie, d_cr]], param_amorph]],
                  [[NoneSpecie, c2]] => [[[[UniqueSpecie, d_cl]], param_amorph]],
                  [[UniqueSpecie, d_cr]] => [[[[NoneSpecie, c1]], param_amorph]],
                  [[UniqueSpecie, d_cl]] => [[[[NoneSpecie, c2]], param_amorph]]
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_activated_methyl_on_incoherent_bridge }
              let(:base_specs) { [dept_methyl_on_bridge_base] }
              let(:specific_specs) { [subject] }
              let(:face_grouped_anchors) { [[cb], [cm]] }
              let(:graph) do
                {
                  [[UniqueSpecie, mob_cb]] => [],
                  [[UniqueSpecie, mob_cm]] => []
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_methyl_on_dimer_base }
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:face_grouped_anchors) { [[cr, cl]] }
              let(:graph) do
                {
                  [[UniqueSpecie, mob_cb]] => [
                    [[[UniqueSpecie, b_ct]], param_100_front]
                  ],
                  [[UniqueSpecie, b_ct]] => [
                    [[[UniqueSpecie, mob_cb]], param_100_front]
                  ]
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_three_bridges_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:face_grouped_anchors) { [[ct], [cc]] }
              let(:graph) do
                {
                  [[SpeciesScope, b_ct]] => [],
                  [[SpeciesScope, b_cr]] => []
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_right_hydrogenated_bridge }
              let(:base_specs) { [dept_bridge_base] }
              let(:specific_specs) { [subject] }
              let(:face_grouped_anchors) { [[cr]] }
              let(:graph) do
                {
                  [[UniqueSpecie, b_cr]] => []
                }
              end
            end

            describe 'different dept_cross_bridge_on_bridges_base' do
              subject { dept_cross_bridge_on_bridges_base }
              let(:face_grouped_anchors) { [[ctl, ctr], [cm]] }

              it_behaves_like :check_graph do
                let(:base_specs) { [dept_bridge_base, subject] }
                let(:graph) do
                  {
                    [[NoneSpecie, cbobs_cm]] => [
                      [[[UniqueSpecie, b_ct], [UniqueSpecie, b_ct]], param_amorph]
                    ],
                    [[UniqueSpecie, b_ct]] => [
                      [[[UniqueSpecie, b_ct]], param_100_cross],
                      [[[NoneSpecie, cbobs_cm]], param_amorph]
                    ],
                    [[UniqueSpecie, b_ct]] => [
                      [[[UniqueSpecie, b_ct]], param_100_cross],
                      [[[NoneSpecie, cbobs_cm]], param_amorph]
                    ]
                  }
                end
              end

              it_behaves_like :check_graph do
                let(:base_specs) do
                  [dept_bridge_base, dept_methyl_on_bridge_base, subject]
                end
                let(:graph) do
                  {
                    [[SpeciesScope, mob_cm]] => [],
                    [[UniqueSpecie, mob_cb]] => [
                      [[[UniqueSpecie, mob_cb]], param_100_cross]
                    ],
                    [[UniqueSpecie, mob_cb]] => [
                      [[[UniqueSpecie, mob_cb]], param_100_cross]
                    ]
                  }
                end
              end
            end

            describe 'different dept_cross_bridge_on_dimers_base' do
              subject { dept_cross_bridge_on_dimers_base }
              let(:face_grouped_anchors) { [[ctr, csr], [ctl, csl], [cm]] }

              it_behaves_like :check_graph do
                let(:base_specs) { [dept_dimer_base, subject] }
                let(:graph) do
                  {
                    [[NoneSpecie, cbods_cm]] => [
                      [[[UniqueSpecie, d_cr], [UniqueSpecie, d_cr]], param_amorph]
                    ],
                    [[UniqueSpecie, d_cr]] => [
                      [[[NoneSpecie, cbods_cm]], param_amorph]
                    ],
                    [[UniqueSpecie, d_cr]] => [
                      [[[NoneSpecie, cbods_cm]], param_amorph]
                    ],
                    [[UniqueSpecie, d_cl], [UniqueSpecie, d_cr]] => [
                      [[[UniqueSpecie, d_cl], [UniqueSpecie, d_cr]], param_100_cross]
                    ],
                    [[UniqueSpecie, d_cl], [UniqueSpecie, d_cr]] => [
                      [[[UniqueSpecie, d_cl], [UniqueSpecie, d_cr]], param_100_cross]
                    ]
                  }
                end
              end

              it_behaves_like :check_graph do
                let(:base_specs) do
                  [dept_dimer_base, dept_methyl_on_dimer_base, subject]
                end
                let(:graph) do
                  {
                    [[SpeciesScope, mod_cm]] => [],
                    [[UniqueSpecie, mod_cr], [UniqueSpecie, mod_cl]] => [
                      [[[UniqueSpecie, mod_cr], [UniqueSpecie, mod_cl]], param_100_cross]
                    ],
                    [[UniqueSpecie, mod_cr], [UniqueSpecie, mod_cl]] => [
                      [[[UniqueSpecie, mod_cr], [UniqueSpecie, mod_cl]], param_100_cross]
                    ]
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
