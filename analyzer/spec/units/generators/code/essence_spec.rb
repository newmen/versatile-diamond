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
            it '#cut_links' do
              expect(essence.cut_links).to match_graph(cut_links)
            end

            it '#raw_algorithm_graph' do
              expect(essence.raw_algorithm_graph).to match_graph(raw_algorithm_graph)
            end

            it '#algorithm_graph' do
              expect(essence.algorithm_graph).to match_graph(algorithm_graph)
            end

            it '#grouped_anchors' do
              expect(essence.grouped_anchors).to match_multidim_array(grouped_anchors)
            end

            it '#central_anchors' do
              expect(essence.central_anchors).to eq(central_anchors)
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
            let(:raw_algorithm_graph) do
              {
                [ct] => [[[cl, cr], [bond_110_cross, bond_110_cross]]],
                [cr] => [[[ct], [bond_110_front]]],
                [cl] => [[[ct], [bond_110_front]]]
              }
            end
            let(:algorithm_graph) do
              {
                ct => [[cl, bond_110_cross], [cr, bond_110_cross]]
              }
            end
            let(:grouped_anchors) { [[ct], [cr], [cl]] }
            let(:central_anchors) { [[ct]] }
          end

          it_behaves_like :check_graphs do
            subject { dept_methyl_on_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_links) do
              {
                cm => [[cb, free_bond]],
                cb => [[cm, free_bond]]
              }
              end
            let(:raw_algorithm_graph) do
              {
                [cm] => [[[cb], [free_bond]]],
                [cb] => [[[cm], [free_bond]]]
              }
            end
            let(:algorithm_graph) do
              {
                cb => [[cm, free_bond]]
              }
            end
            let(:grouped_anchors) { [[cb], [cm]] }
            let(:central_anchors) { [[cb]] }
          end

          it_behaves_like :check_graphs do
            subject { dept_high_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_links) do
              {
                cm => [[cb, free_bond]],
                cb => [[cm, free_bond]],
              }
            end
            let(:raw_algorithm_graph) do
              {
                [cm] => [[[cb], [free_bond]]],
                [cb] => [[[cm], [free_bond]]]
              }
            end
            let(:algorithm_graph) do
              {
                cb => [[cm, free_bond]]
              }
            end
            let(:grouped_anchors) { [[cb], [cm]] }
            let(:central_anchors) { [[cb]] }
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
            let(:raw_algorithm_graph) do
              {
                [cb] => [[[c1], [free_bond]]],
                [c1] => [[[cb], [free_bond]], [[c2], [free_bond]]],
                [c2] => [[[c1], [free_bond]]]
              }
            end
            let(:algorithm_graph) do
              {
                cb => [[c1, free_bond]],
                c1 => [[c2, free_bond]]
              }
            end
            let(:grouped_anchors) { [[cb], [c1], [c2]] }
            let(:central_anchors) { [[cb]] }
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
            let(:raw_algorithm_graph) do
              {
                [cr] => [[[cl], [bond_100_front]]],
                [cl] => [[[cr], [bond_100_front]]]
              }
            end
            let(:algorithm_graph) do
              {
                cr => [[cl, bond_100_front]]
              }
            end
            let(:grouped_anchors) { [[cr, cl]] }
            let(:central_anchors) { [[cr]] }
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
            let(:raw_algorithm_graph) do
              {
                [c1] => [[[cr], [free_bond]]],
                [c2] => [[[cl], [free_bond]]],
                [cr] => [[[c1], [free_bond]]],
                [cl] => [[[c2], [free_bond]]]
              }
            end
            let(:algorithm_graph) do
              {
                cr => [[c1, free_bond]],
                cl => [[c2, free_bond]]
              }
            end
            let(:grouped_anchors) { [[cr, cl], [c1], [c2]] }
            let(:central_anchors) { [[cl, cr]] }
          end

          shared_examples_for :check_same_graphs do
            it_behaves_like :check_graphs do
              let(:algorithm_graph) { cut_links }
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
            let(:raw_algorithm_graph) do
              {
                [cb] => [],
                [cm] => []
              }
            end
            let(:grouped_anchors) { [[cb], [cm]] }
            let(:central_anchors) { [[cb, cm]] }
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
            let(:raw_algorithm_graph) do
              {
                [cr] => [[[cl], [bond_100_front]]],
                [cl] => [[[cr], [bond_100_front]]]
              }
            end
            let(:grouped_anchors) { [[cr, cl]] }
            let(:central_anchors) { [[cr], [cl]] }
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
            let(:raw_algorithm_graph) do
              {
                [ct] => [],
                [cc] => []
              }
            end
            let(:grouped_anchors) { [[ct], [cc]] }
            let(:central_anchors) { [[cc]] }
          end

          shared_examples_for :check_same_graphs_and_anchors do
            it_behaves_like :check_same_graphs do
              let(:raw_algorithm_graph) do
                Hash[cut_links.map { |k, v| [[k], v] }]
              end
              let(:grouped_anchors) { central_anchors }
              let(:central_anchors) { [cut_links.keys] }
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
            subject { dept_activated_bridge }
            let(:base_specs) { [dept_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:cut_links) do
              {
                ct => []
              }
            end
          end

          it_behaves_like :check_same_graphs_and_anchors do
            subject { dept_activated_methyl_on_bridge }
            let(:base_specs) { [dept_methyl_on_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:cut_links) do
              {
                cm => []
              }
            end
          end

          it_behaves_like :check_same_graphs_and_anchors do
            subject { dept_activated_methyl_on_incoherent_bridge }
            let(:specific_specs) { [dept_activated_methyl_on_bridge, subject] }
            let(:cut_links) do
              {
                cb => []
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
            let(:grouped_anchors) { [[ctl, ctr], [cm]] }

            it_behaves_like :check_graphs do
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:cut_links) do
                {
                  cm => [[ctl, free_bond], [ctr, free_bond]],
                  ctr => [[ctl, position_100_cross], [cm, free_bond]],
                  ctl => [[ctr, position_100_cross], [cm, free_bond]],
                }
              end
              let(:raw_algorithm_graph) do
                {
                  [cm] => [[[ctr, ctl], [free_bond, free_bond]]],
                  [ctr] => [[[ctl], [position_100_cross]], [[cm], [free_bond]]],
                  [ctl] => [[[ctr], [position_100_cross]], [[cm], [free_bond]]],
                }
              end
              let(:algorithm_graph) do
                {
                  ctr => [[cm, free_bond]],
                  ctl => [[cm, free_bond], [ctr, position_100_cross]]
                }
              end
              let(:central_anchors) { [[ctl]] }
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
              let(:raw_algorithm_graph) do
                {
                  [cm] => [],
                  [ctr] => [[[ctl], [position_100_cross]]],
                  [ctl] => [[[ctr], [position_100_cross]]],
                }
              end
              let(:algorithm_graph) do
                {
                  cm => [],
                  ctl => [[ctr, position_100_cross]],
                }
              end
              let(:central_anchors) { [[cm]] }
            end
          end

          describe 'different dept_cross_bridge_on_dimers_base' do
            subject { dept_cross_bridge_on_dimers_base }
            let(:grouped_anchors) { [[ctr, csr], [ctl, csl], [cm]] }

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
              let(:raw_algorithm_graph) do
                {
                  [cm] => [[[ctr, ctl], [free_bond, free_bond]]],
                  [ctl] => [[[cm], [free_bond]]],
                  [ctr] => [[[cm], [free_bond]]],
                  [csr, ctr] => [
                    [[csl, ctl], [position_100_cross, position_100_cross]]],
                  [csl, ctl] => [
                    [[csr, ctr], [position_100_cross, position_100_cross]]]
                }
              end
              let(:algorithm_graph) do
                {
                  ctl => [[cm, free_bond]],
                  ctr => [[cm, free_bond], [ctl, position_100_cross]],
                  csr => [[csl, position_100_cross]],
                }
              end
              let(:central_anchors) { [[csr], [ctr]] }
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
              let(:raw_algorithm_graph) do
                {
                  [cm] => [],
                  [csr, ctr] => [
                    [[csl, ctl], [position_100_cross, position_100_cross]]],
                  [csl, ctl] => [
                    [[csr, ctr], [position_100_cross, position_100_cross]]]
                }
              end
              let(:algorithm_graph) do
                {
                  cm => [],
                  ctr => [[ctl, position_100_cross]],
                  csr => [[csl, position_100_cross]],
                }
              end
              let(:central_anchors) { [[cm]] }
            end
          end
        end
      end

    end
  end
end
