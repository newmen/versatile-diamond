require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe SpecieBackbone, type: :algorithm do
          let(:base_specs) { [] }
          let(:specific_specs) { [] }
          let(:typical_reactions) { [] }
          let(:generator) do
            stub_generator(
              base_specs: base_specs,
              specific_specs: specific_specs,
              typical_reactions: typical_reactions)
          end

          let(:specie) { generator.specie_class(subject.name) }
          let(:backbone) { described_class.new(generator, specie) }

          Support::RoleChecker::ANCHOR_KEYNAMES.each do |keyname|
            let(keyname) { subject.spec.atom(keyname) }
          end

          describe '#final_graph' do
            it_behaves_like :check_finite_graph do
              subject { dept_bridge_base }
              let(:base_specs) { [subject] }
              let(:final_graph) do
                {
                  [ct] => [[[cl, cr], param_110_cross]]
                }
              end
            end

            it_behaves_like :check_finite_graph do
              subject { dept_methyl_on_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:final_graph) do
                {
                  [cb] => [[[cm], param_amorph]]
                }
              end
            end

            it_behaves_like :check_finite_graph do
              subject { dept_vinyl_on_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:final_graph) do
                {
                  [cb] => [[[c1], param_amorph]],
                  [c1] => [[[c2], param_amorph]],
                }
              end
            end

            it_behaves_like :check_finite_graph do
              subject { dept_dimer_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:final_graph) do
                {
                  [cr] => [[[cl], param_100_front]]
                }
              end
            end

            describe 'different dept_two_methyls_on_dimer_base' do
              subject { dept_two_methyls_on_dimer_base }

              it_behaves_like :check_finite_graph do
                let(:base_specs) { [dept_dimer_base, subject] }
                let(:final_graph) do
                  {
                    [cr] => [[[c1], param_amorph]],
                    [cl] => [[[c2], param_amorph]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:base_specs) { [dept_dimer_base, subject] }
                let(:typical_reactions) do
                  [
                    dept_hydrogen_abs_from_gap,
                    dept_incoherent_dimer_drop,
                    dept_intermed_migr_dh_drop
                  ]
                end
                let(:final_graph) do
                  {
                    [cl] => [],
                    [cr] => [[[c1], param_amorph]],
                    [c1] => []
                  }
                end
              end
            end

            it_behaves_like :check_finite_graph do
              subject { dept_activated_methyl_on_incoherent_bridge }
              let(:base_specs) { [dept_methyl_on_bridge_base] }
              let(:specific_specs) { [subject] }
              let(:final_graph) do
                {
                  [cb, cm] => [],
                }
              end
            end

            it_behaves_like :check_finite_graph do
              subject { dept_methyl_on_dimer_base }
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:final_graph) do
                {
                  [cr] => [[[cl], param_100_front]],
                  [cl] => [[[cr], param_100_front]]
                }
              end
            end

            it_behaves_like :check_finite_graph do
              subject { dept_three_bridges_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:final_graph) do
                {
                  [ct] => [],
                  [cc] => []
                }
              end
            end

            it_behaves_like :check_finite_graph do
              subject { dept_activated_dimer }
              let(:base_specs) { [dept_dimer_base] }
              let(:specific_specs) { [subject] }
              let(:final_graph) do
                {
                  [cr] => []
                }
              end
            end

            describe 'different dept_lower_methyl_on_half_extended_bridge_base' do
              subject { dept_lower_methyl_on_half_extended_bridge_base }

              it_behaves_like :check_finite_graph do
                let(:base_specs) { [dept_bridge_base, subject] }
                let(:final_graph) do
                  {
                    [cr] => [],
                    [cbr] => [[[cm], param_amorph]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:base_specs) do
                  [dept_bridge_base, dept_methyl_on_right_bridge_base, subject]
                end
                let(:final_graph) do
                  {
                    [cr] => [[[cbr], param_110_cross]],
                    [cbr] => [[[cr], param_110_front]]
                  }
                end
              end
            end

            describe 'different dept_cross_bridge_on_bridges_base' do
              subject { dept_cross_bridge_on_bridges_base }

              it_behaves_like :check_finite_graph do
                let(:base_specs) { [dept_bridge_base, subject] }
                let(:final_graph) do
                  {
                    [ctr] => [[[cm], param_amorph]],
                    [ctl] => [[[cm], param_amorph], [[ctr], param_100_cross]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:base_specs) do
                  [dept_bridge_base, dept_methyl_on_bridge_base, subject]
                end
                let(:final_graph) do
                  {
                    [cm] => [],
                    [ctl] => [[[ctr], param_100_cross]]
                  }
                end
              end
            end

            describe 'different dept_cross_bridge_on_dimers_base' do
              subject { dept_cross_bridge_on_dimers_base }

              it_behaves_like :check_finite_graph do
                let(:base_specs) { [dept_dimer_base, subject] }
                let(:final_graph) do
                  {
                    [ctl] => [[[cm], param_amorph]],
                    [ctr] => [[[cm], param_amorph]],
                    [csr, ctr] => [[[csl, ctl], param_100_cross]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:base_specs) do
                  [dept_dimer_base, dept_methyl_on_dimer_base, subject]
                end
                let(:final_graph) do
                  {
                    [cm] => [],
                    [csr, ctr] => [[[csl, ctl], param_100_cross]]
                  }
                end
              end
            end

            describe 'intermediate specie of migration down process' do
              let(:base_specs) do
                [
                  dept_bridge_base,
                  dept_methyl_on_bridge_base,
                  dept_methyl_on_dimer_base,
                  subject
                ]
              end

              it_behaves_like :check_finite_graph do
                subject { dept_intermed_migr_down_common_base }
                let(:final_graph) do
                  {
                    [cm] => [],
                    [cbr] => [[[cdr], param_100_cross]],
                    [cdr] => [[[cm], param_amorph]]
                  }
                end
              end

              describe 'both lower atoms are related' do
                let(:final_graph) do
                  {
                    [cm] => [],
                    [cbr, cbl] => [[[cdr, cdl], param_100_cross]],
                    [cdr] => [[[cm], param_amorph]]
                  }
                end

                it_behaves_like :check_finite_graph do
                  subject { dept_intermed_migr_down_half_base }
                end

                it_behaves_like :check_finite_graph do
                  subject { dept_intermed_migr_down_full_base }
                end
              end
            end
          end

          describe '#ordered_graph_from' do
            it_behaves_like :check_ordered_graph do
              subject { dept_bridge_base }
              let(:base_specs) { [subject] }
              let(:ordered_graph) do
                [
                  [[ct], [[[cl, cr], param_110_cross]]]
                ]
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { dept_vinyl_on_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:ordered_graph) do
                [
                  [[cb], [[[c1], param_amorph]]],
                  [[c1], [[[c2], param_amorph]]]
                ]
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { dept_dimer_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:ordered_graph) do
                [
                  [[cr], [[[cl], param_100_front]]]
                ]
              end
            end

            describe 'different dept_two_methyls_on_dimer_base' do
              subject { dept_two_methyls_on_dimer_base }

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_dimer_base, subject] }
                let(:ordered_graph) do
                  [
                    [[cr], [[[c1], param_amorph]]],
                    [[cl], [[[c2], param_amorph]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_dimer_base, subject] }
                let(:typical_reactions) do
                  [
                    dept_hydrogen_abs_from_gap,
                    dept_incoherent_dimer_drop,
                    dept_intermed_migr_dh_drop
                  ]
                end
                let(:ordered_graph) do
                  [
                    [[cl], []],
                    [[cr], [[[c1], param_amorph]]],
                    [[c1], []]
                  ]
                end
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { dept_activated_methyl_on_incoherent_bridge }
              let(:base_specs) { [dept_methyl_on_bridge_base] }
              let(:specific_specs) { [subject] }
              let(:ordered_graph) do
                [
                  [[cm, cb], []],
                ]
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { dept_three_bridges_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:ordered_graph) do
                [
                  [[cc], []],
                  [[ct], []]
                ]
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { dept_bridge_with_dimer_base }
              let(:base_specs) { [dept_bridge_base, dept_dimer_base, subject] }
              let(:ordered_graph) do
                [
                  [[cr], []],
                  [[ct], []]
                ]
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { dept_bridge_with_dimer_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:ordered_graph) do
                [
                  [[cr], [[[cl], param_100_front]]],
                  [[ct], []]
                ]
              end
            end

            describe 'under up migration through 111 face' do
              subject { dept_lower_methyl_on_half_extended_bridge_base }

              describe 'just bridge base' do
                let(:base_specs) { [dept_bridge_base, subject] }

                it_behaves_like :check_ordered_graph do
                  let(:entry_node) { backbone.entry_nodes.first }
                  let(:ordered_graph) do
                    [
                      [[cbr], [[[cm], param_amorph]]],
                      [[cr], []]
                    ]
                  end
                end

                it_behaves_like :check_ordered_graph do
                  let(:entry_node) { backbone.entry_nodes.last }
                  let(:ordered_graph) do
                    [
                      [[cr], []],
                      [[cbr], [[[cm], param_amorph]]]
                    ]
                  end
                end
              end

              describe 'many base species' do
                let(:base_specs) do
                  [dept_bridge_base, dept_methyl_on_right_bridge_base, subject]
                end

                it_behaves_like :check_ordered_graph do
                  let(:entry_node) { backbone.entry_nodes.first }
                  let(:ordered_graph) do
                    [
                      [[cbr], [[[cr], param_110_front]]]
                    ]
                  end
                end

                it_behaves_like :check_ordered_graph do
                  let(:entry_node) { backbone.entry_nodes.last }
                  let(:ordered_graph) do
                    [
                      [[cr], [[[cbr], param_110_cross]]]
                    ]
                  end
                end
              end
            end

            describe 'under down migration through 111 face' do
              subject { dept_top_methyl_on_half_extended_bridge_base }
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end

              it_behaves_like :check_ordered_graph do
                let(:entry_node) { backbone.entry_nodes.first }
                let(:ordered_graph) do
                  [
                    [[ct], [[[cr], param_110_cross]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:entry_node) { backbone.entry_nodes.last }
                let(:ordered_graph) do
                  [
                    [[cr], [[[ct], param_110_front]]]
                  ]
                end
              end
            end

            describe 'multi anchored dept_cross_bridge_on_bridges_base' do
              subject { dept_cross_bridge_on_bridges_base }

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base, subject] }
                let(:ordered_graph) do
                  [
                    [[ctl], [[[cm], param_amorph], [[ctr], param_100_cross]]],
                    [[ctr], [[[cm], param_amorph]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:base_specs) do
                  [dept_bridge_base, dept_methyl_on_bridge_base, subject]
                end
                let(:ordered_graph) do
                  [
                    [[cm], []],
                    [[ctl], [[[ctr], param_100_cross]]]
                  ]
                end
              end
            end

            describe 'different dept_cross_bridge_on_dimers_base' do
              subject { dept_cross_bridge_on_dimers_base }
              let(:base_specs) { [dept_bridge_base, dept_dimer_base, subject] }

              it_behaves_like :check_ordered_graph do
                let(:ordered_graph) do
                  [
                    [[ctr], [[[cm], param_amorph]]],
                    [[ctr, csr], [[[ctl, csl], param_100_cross]]],
                    [[ctl], [[[cm], param_amorph]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:typical_reactions) do
                  [
                    dept_sierpinski_drop,
                    dept_incoherent_dimer_drop
                  ]
                end
                let(:ordered_graph) do
                  [
                    [[csl, csr], [[[ctl, ctr], param_100_front]]],
                    [[csr], [[[csl], param_100_cross]]]
                  ]
                end
              end
            end

            describe 'different anchors of dept_methyl_on_dimer_base' do
              subject { dept_methyl_on_dimer_base }
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end

              it_behaves_like :check_ordered_graph do
                let(:entry_node) { backbone.entry_nodes.first }
                let(:ordered_graph) do
                  [
                    [[cr], [[[cl], param_100_front]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:entry_node) { backbone.entry_nodes.last }
                let(:ordered_graph) do
                  [
                    [[cl], [[[cr], param_100_front]]]
                  ]
                end
              end
            end

            describe 'intermediate specie of migration down process' do
              let(:base_specs) do
                [
                  dept_bridge_base,
                  dept_methyl_on_bridge_base,
                  dept_methyl_on_dimer_base,
                  subject
                ]
              end

              describe 'both lower atoms are half related' do
                subject { dept_intermed_migr_down_common_base }

                it_behaves_like :check_ordered_graph do
                  let(:entry_node) { backbone.entry_nodes.first }
                  let(:ordered_graph) do
                    [
                      [[cdr], [[[cm], param_amorph]]],
                      [[cm], []],
                      [[cbr], [[[cdr], param_100_cross]]]
                    ]
                  end
                end

                it_behaves_like :check_ordered_graph do
                  let(:entry_node) { backbone.entry_nodes.last }
                  let(:ordered_graph) do
                    [
                      [[cm], []],
                      [[cbr], [[[cdr], param_100_cross]]],
                      [[cdr], [[[cm], param_amorph]]]
                    ]
                  end
                end
              end

              describe 'both lower atoms are related from dimer' do
                let(:entry_node) { backbone.entry_nodes.first }
                let(:ordered_graph) do
                  [
                    [[cdr], [[[cm], param_amorph]]],
                    [[cm], []],
                    [[cbl, cbr], [[[cdl, cdr], param_100_cross]]]
                  ]
                end

                it_behaves_like :check_ordered_graph do
                  subject { dept_intermed_migr_down_half_base }
                end

                it_behaves_like :check_ordered_graph do
                  subject { dept_intermed_migr_down_full_base }
                end
              end

              describe 'both lower atoms are related from adsorbed methyl' do
                let(:entry_node) { backbone.entry_nodes.last }
                let(:ordered_graph) do
                  [
                    [[cm], []],
                    [[cbl, cbr], [[[cdl, cdr], param_100_cross]]],
                    [[cdr], [[[cm], param_amorph]]]
                  ]
                end

                it_behaves_like :check_ordered_graph do
                  subject { dept_intermed_migr_down_half_base }
                end

                it_behaves_like :check_ordered_graph do
                  subject { dept_intermed_migr_down_full_base }
                end
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { dept_intermed_migr_down_bridge_base }
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:cbt) { intermed_migr_down_bridge_base.atom(:cbt) }
              let(:ordered_graph) do
                [
                  [[cm], []],
                  [[cbr], [[[cbt], param_100_cross]]]
                ]
              end
            end
          end
        end

      end
    end
  end
end
