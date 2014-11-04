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

            shared_examples_for :check_graph do
              def typed_node(node)
                [node.first.class, node.last.atom]
              end

              # each method should not change the state of grouped nodes graph
              it 'all public methods' do
                anchors =
                  grouped_nodes.face_grouped_nodes.map do |nodes|
                    nodes.map(&:last).map(&:atom)
                  end

                expect(anchors).to match_multidim_array(face_grouped_anchors)

                fg = grouped_nodes.final_graph
                typed_graph =
                  fg.each_with_object({}) do |(nodes, rels), acc|
                    acc[nodes.map(&method(:typed_node))] = rels.map do |ns, r|
                      [ns.map(&method(:typed_node)), r]
                    end
                  end

                expect(typed_graph).to match_graph(grouped_graph)
              end
            end

            it_behaves_like :check_graph do
              subject { dept_bridge_base }
              let(:base_specs) { [subject] }
              let(:face_grouped_anchors) { [[ct], [cr], [cl]] }
              let(:grouped_graph) do
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
              let(:grouped_graph) do
                {
                  [[NoneSpecie, cm]] => [[[[UniqueSpecie, cb]], param_amorph]],
                  [[UniqueSpecie, cb]] => [[[[NoneSpecie, cm]], param_amorph]]
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
              let(:grouped_graph) do
                {
                  [[UniqueSpecie, cb]] => [[[[NoneSpecie, c1]], param_amorph]],
                  [[NoneSpecie, c2]] => [[[[NoneSpecie, c1]], param_amorph]],
                  [[NoneSpecie, c1]] => [
                    [[[UniqueSpecie, cb]], param_amorph],
                    [[[NoneSpecie, c2]], param_amorph]
                  ]
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_dimer_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:face_grouped_anchors) { [[cr, cl]] }
              let(:grouped_graph) do
                {
                  [[UniqueSpecie, cr]] => [
                    [[[UniqueSpecie, cl]], param_100_front]
                  ],
                  [[UniqueSpecie, cl]] => [
                    [[[UniqueSpecie, cr]], param_100_front]
                  ]
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_two_methyls_on_dimer_base }
              let(:base_specs) { [dept_dimer_base, subject] }
              let(:face_grouped_anchors) { [[cr, cl], [c1], [c2]] }
              let(:grouped_graph) do
                {
                  [[NoneSpecie, c1]] => [[[[UniqueSpecie, cr]], param_amorph]],
                  [[NoneSpecie, c2]] => [[[[UniqueSpecie, cl]], param_amorph]],
                  [[UniqueSpecie, cr]] => [[[[NoneSpecie, c1]], param_amorph]],
                  [[UniqueSpecie, cl]] => [[[[NoneSpecie, c2]], param_amorph]]
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_activated_methyl_on_incoherent_bridge }
              let(:base_specs) { [dept_methyl_on_bridge_base] }
              let(:specific_specs) { [subject] }
              let(:face_grouped_anchors) { [[cb], [cm]] }
              let(:grouped_graph) do
                {
                  [[UniqueSpecie, cb]] => [],
                  [[UniqueSpecie, cm]] => []
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_methyl_on_dimer_base }
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:face_grouped_anchors) { [[cr, cl]] }
              let(:grouped_graph) do
                {
                  [[UniqueSpecie, cr]] => [
                    [[[UniqueSpecie, cl]], param_100_front]
                  ],
                  [[UniqueSpecie, cl]] => [
                    [[[UniqueSpecie, cr]], param_100_front]
                  ]
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_three_bridges_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:face_grouped_anchors) { [[ct], [cc]] }
              let(:grouped_graph) do
                {
                  [[SpeciesScope, ct]] => [],
                  [[SpeciesScope, cc]] => []
                }
              end
            end

            it_behaves_like :check_graph do
              subject { dept_right_hydrogenated_bridge }
              let(:base_specs) { [dept_bridge_base] }
              let(:specific_specs) { [subject] }
              let(:face_grouped_anchors) { [[cr]] }
              let(:grouped_graph) do
                {
                  [[UniqueSpecie, cr]] => []
                }
              end
            end

            describe 'different dept_cross_bridge_on_bridges_base' do
              subject { dept_cross_bridge_on_bridges_base }
              let(:face_grouped_anchors) { [[ctl, ctr], [cm]] }

              it_behaves_like :check_graph do
                let(:base_specs) { [dept_bridge_base, subject] }
                let(:grouped_graph) do
                  {
                    [[NoneSpecie, cm]] => [
                      [[[UniqueSpecie, ctr], [UniqueSpecie, ctl]], param_amorph]
                    ],
                    [[UniqueSpecie, ctr]] => [
                      [[[UniqueSpecie, ctl]], param_100_cross],
                      [[[NoneSpecie, cm]], param_amorph]
                    ],
                    [[UniqueSpecie, ctl]] => [
                      [[[UniqueSpecie, ctr]], param_100_cross],
                      [[[NoneSpecie, cm]], param_amorph]
                    ]
                  }
                end
              end

              it_behaves_like :check_graph do
                let(:base_specs) do
                  [dept_bridge_base, dept_methyl_on_bridge_base, subject]
                end
                let(:grouped_graph) do
                  {
                    [[SpeciesScope, cm]] => [],
                    [[UniqueSpecie, ctr]] => [
                      [[[UniqueSpecie, ctl]], param_100_cross]
                    ],
                    [[UniqueSpecie, ctl]] => [
                      [[[UniqueSpecie, ctr]], param_100_cross]
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
                let(:grouped_graph) do
                  {
                    [[NoneSpecie, cm]] => [
                      [[[UniqueSpecie, ctr], [UniqueSpecie, ctl]], param_amorph]
                    ],
                    [[UniqueSpecie, ctr]] => [
                      [[[NoneSpecie, cm]], param_amorph]
                    ],
                    [[UniqueSpecie, ctl]] => [
                      [[[NoneSpecie, cm]], param_amorph]
                    ],
                    [[UniqueSpecie, csr], [UniqueSpecie, ctr]] => [
                      [[[UniqueSpecie, csl], [UniqueSpecie, ctl]], param_100_cross]
                    ],
                    [[UniqueSpecie, csl], [UniqueSpecie, ctl]] => [
                      [[[UniqueSpecie, csr], [UniqueSpecie, ctr]], param_100_cross]
                    ]
                  }
                end
              end

              it_behaves_like :check_graph do
                let(:base_specs) do
                  [dept_dimer_base, dept_methyl_on_dimer_base, subject]
                end
                let(:grouped_graph) do
                  {
                    [[SpeciesScope, cm]] => [],
                    [[UniqueSpecie, csr], [UniqueSpecie, ctr]] => [
                      [[[UniqueSpecie, csl], [UniqueSpecie, ctl]], param_100_cross]
                    ],
                    [[UniqueSpecie, csl], [UniqueSpecie, ctl]] => [
                      [[[UniqueSpecie, csr], [UniqueSpecie, ctr]], param_100_cross]
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
