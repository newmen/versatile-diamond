require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Essence, use: :engine_generator do
        let(:base_specs) { [] }
        let(:specific_specs) { [] }
        let(:generator) do
          stub_generator(base_specs: base_specs, specific_specs: specific_specs)
        end

        let(:specie) { generator.specie_class(subject.name) }
        let(:essence) { described_class.new(specie) }

        describe 'graphs' do
          [
            :ct, :cr, :cl, :cb, :cm, :cc, :c1, :c2, :ctl, :ctr, :csl, :csr
          ].each do |keyname|
            let(keyname) { subject.spec.atom(keyname) }
          end

          shared_examples_for :check_graphs do
            # each method should not change the state of essence
            it 'all public methods' do
              expect(essence.cut_links).to match_graph(cut_links)
              expect(essence.grouped_graph).to match_graph(grouped_graph)
              expect(essence.face_grouped_anchors).
                to match_multidim_array(face_grouped_anchors)
            end
          end

          it_behaves_like :check_graphs do
            subject { dept_bridge_base }
            let(:base_specs) { [subject] }
            let(:cut_links) do
              {
                ct => [[cl, bond_110_cross], [cr, bond_110_cross]],
                cr => [[ct, bond_110_front]],
                cl => [[ct, bond_110_front]]
              }
            end
            let(:face_grouped_anchors) { [[ct], [cr], [cl]] }
            let(:grouped_graph) do
              {
                [ct] => [[[cl, cr], param_110_cross]],
                [cr] => [[[ct], param_110_front]],
                [cl] => [[[ct], param_110_front]]
              }
            end
          end

          describe 'like methyl on bridge' do
            let(:cut_links) do
              {
                cm => [[cb, free_bond]],
                cb => [[cm, free_bond]]
              }
            end
            let(:face_grouped_anchors) { [[cb], [cm]] }
            let(:grouped_graph) do
              {
                [cm] => [[[cb], param_amorph]],
                [cb] => [[[cm], param_amorph]]
              }
            end

            it_behaves_like :check_graphs do
              subject { dept_methyl_on_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
            end

            it_behaves_like :check_graphs do
              subject { dept_high_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
            end
          end

          it_behaves_like :check_graphs do
            subject { dept_vinyl_on_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_links) do
              {
                cb => [[c1, free_bond]],
                c1 => [[cb, free_bond], [c2, free_bond]],
                c2 => [[c1, free_bond]]
              }
            end
            let(:face_grouped_anchors) { [[cb], [c1], [c2]] }
            let(:grouped_graph) do
              {
                [cb] => [[[c1], param_amorph]],
                [c1] => [[[cb], param_amorph], [[c2], param_amorph]],
                [c2] => [[[c1], param_amorph]]
              }
            end
          end

          it_behaves_like :check_graphs do
            subject { dept_dimer_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_links) do
              {
                cr => [[cl, bond_100_front]],
                cl => [[cr, bond_100_front]]
              }
            end
            let(:face_grouped_anchors) { [[cr, cl]] }
            let(:grouped_graph) do
              {
                [cr] => [[[cl], param_100_front]],
                [cl] => [[[cr], param_100_front]]
              }
            end
          end

          it_behaves_like :check_graphs do
            subject { dept_two_methyls_on_dimer_base }
            let(:base_specs) { [dept_dimer_base, subject] }
            let(:cut_links) do
              {
                c1 => [[cr, free_bond]],
                c2 => [[cl, free_bond]],
                cr => [[c1, free_bond]],
                cl => [[c2, free_bond]]
              }
            end
            let(:face_grouped_anchors) { [[cr, cl], [c1], [c2]] }
            let(:grouped_graph) do
              {
                [c1] => [[[cr], param_amorph]],
                [c2] => [[[cl], param_amorph]],
                [cr] => [[[c1], param_amorph]],
                [cl] => [[[c2], param_amorph]]
              }
            end
          end

          shared_examples_for :check_same_graphs do
            it_behaves_like :check_graphs do
              let(:grouped_graph) do
                wrapped_rels = cut_links.map do |k, v|
                  rels =
                    if v.empty?
                      []
                    else
                      params = v.first.last.params
                      v.map { |a, r| [[a], params] }
                    end
                  [[k], rels]
                end
                Hash[wrapped_rels]
              end
            end
          end

          it_behaves_like :check_same_graphs do
            subject { dept_activated_methyl_on_incoherent_bridge }
            let(:base_specs) { [dept_methyl_on_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:cut_links) do
              {
                cb => [],
                cm => []
              }
            end
            let(:face_grouped_anchors) { [[cb], [cm]] }
          end

          it_behaves_like :check_same_graphs do
            subject { dept_methyl_on_dimer_base }
            let(:base_specs) do
              [dept_bridge_base, dept_methyl_on_bridge_base, subject]
            end
            let(:cut_links) do
              {
                cr => [[cl, bond_100_front]],
                cl => [[cr, bond_100_front]]
              }
            end
            let(:face_grouped_anchors) { [[cr, cl]] }
          end

          it_behaves_like :check_same_graphs do
            subject { dept_three_bridges_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_links) do
              {
                ct => [],
                cc => []
              }
            end
            let(:face_grouped_anchors) { [[ct], [cc]] }
          end

          shared_examples_for :check_same_graphs_and_anchors do
            it_behaves_like :check_same_graphs do
              let(:face_grouped_anchors) { [cut_links.keys] }
            end
          end

          it_behaves_like :check_same_graphs_and_anchors do
            subject { dept_right_hydrogenated_bridge }
            let(:base_specs) { [dept_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:cut_links) do
              {
                cr => []
              }
            end
          end

          it_behaves_like :check_same_graphs_and_anchors do
            subject { dept_activated_dimer }
            let(:base_specs) { [dept_dimer_base] }
            let(:specific_specs) { [subject] }
            let(:cut_links) do
              {
                cr => []
              }
            end
          end

          describe 'different dept_cross_bridge_on_bridges_base' do
            subject { dept_cross_bridge_on_bridges_base }
            let(:face_grouped_anchors) { [[ctl, ctr], [cm]] }

            it_behaves_like :check_graphs do
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:cut_links) do
                {
                  cm => [[ctl, free_bond], [ctr, free_bond]],
                  ctr => [[ctl, position_100_cross], [cm, free_bond]],
                  ctl => [[ctr, position_100_cross], [cm, free_bond]],
                }
              end
              let(:grouped_graph) do
                {
                  [cm] => [[[ctr, ctl], param_amorph]],
                  [ctr] => [[[ctl], param_100_cross], [[cm], param_amorph]],
                  [ctl] => [[[ctr], param_100_cross], [[cm], param_amorph]],
                }
              end
            end

            it_behaves_like :check_graphs do
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:cut_links) do
                {
                  cm => [],
                  ctr => [[ctl, position_100_cross]],
                  ctl => [[ctr, position_100_cross]],
                }
              end
              let(:grouped_graph) do
                {
                  [cm] => [],
                  [ctr] => [[[ctl], param_100_cross]],
                  [ctl] => [[[ctr], param_100_cross]],
                }
              end
            end
          end

          describe 'different dept_cross_bridge_on_dimers_base' do
            subject { dept_cross_bridge_on_dimers_base }
            let(:face_grouped_anchors) { [[ctr, csr], [ctl, csl], [cm]] }

            it_behaves_like :check_graphs do
              let(:base_specs) { [dept_dimer_base, subject] }
              let(:cut_links) do
                {
                  cm => [[ctl, free_bond], [ctr, free_bond]],
                  ctr => [[ctl, position_100_cross], [cm, free_bond]],
                  ctl => [[ctr, position_100_cross], [cm, free_bond]],
                  csr => [[csl, position_100_cross]],
                  csl => [[csr, position_100_cross]],
                }
              end
              let(:grouped_graph) do
                {
                  [cm] => [[[ctr, ctl], param_amorph]],
                  [ctl] => [[[cm], param_amorph]],
                  [ctr] => [[[cm], param_amorph]],
                  [csr, ctr] => [[[csl, ctl], param_100_cross]],
                  [csl, ctl] => [[[csr, ctr], param_100_cross]]
                }
              end
            end

            it_behaves_like :check_graphs do
              let(:base_specs) do
                [dept_dimer_base, dept_methyl_on_dimer_base, subject]
              end
              let(:cut_links) do
                {
                  cm => [],
                  ctr => [[ctl, position_100_cross]],
                  ctl => [[ctr, position_100_cross]],
                  csr => [[csl, position_100_cross]],
                  csl => [[csr, position_100_cross]],
                }
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
