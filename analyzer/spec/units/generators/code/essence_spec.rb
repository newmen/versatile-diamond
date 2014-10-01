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
            describe '#cut_graph' do
              it { expect(essence.cut_graph).to match_graph(cut_graph) }
            end

            describe '#algorithm_graph' do
              it { expect(essence.algorithm_graph).to match_graph(algorithm_graph) }
            end

            describe '#central_anchors' do
              it { expect(essence.central_anchors).to eq(central_anchors) }
            end
          end

          it_behaves_like :check_graphs do
            subject { dept_bridge_base }
            let(:base_specs) { [subject] }
            let(:cut_graph) do
              {
                ct => [[cl, bond_110_cross], [cr, bond_110_cross]],
                cr => [[ct, bond_110_front]],
                cl => [[ct, bond_110_front]],
              }
            end
            let(:algorithm_graph) do
              { ct => [[cl, bond_110_cross], [cr, bond_110_cross]] }
            end
            let(:central_anchors) { [[ct]] }
          end

          it_behaves_like :check_graphs do
            subject { dept_methyl_on_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_graph) { { cm => [[cb, free_bond]], cb => [[cm, free_bond]] } }
            let(:algorithm_graph) { { cb => [[cm, free_bond]] } }
            let(:central_anchors) { [[cb]] }
          end

          it_behaves_like :check_graphs do
            subject { dept_high_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_graph) do
              {
                cm => [[cb, free_bond], [cb, free_bond]],
                cb => [[cm, free_bond], [cm, free_bond]],
              }
            end
            let(:algorithm_graph) { { cb => [[cm, free_bond]] } }
            let(:central_anchors) { [[cb]] }
          end

          it_behaves_like :check_graphs do
            subject { dept_vinyl_on_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_graph) do
              {
                cb => [[c1, free_bond]],
                c1 => [[cb, free_bond], [c2, free_bond], [c2, free_bond]],
                c2 => [[c1, free_bond], [c1, free_bond]]
              }
            end
            let(:algorithm_graph) { { cb => [[c1, free_bond]], c1 => [[c2, free_bond]] } }
            let(:central_anchors) { [[cb]] }
          end

          it_behaves_like :check_graphs do
            subject { dept_dimer_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_graph) do
              { cr => [[cl, bond_100_front]], cl => [[cr, bond_100_front]] }
            end
            let(:algorithm_graph) { { cr => [[cl, bond_100_front]] } }
            let(:central_anchors) { [[cr]] }
          end

          it_behaves_like :check_graphs do
            subject { dept_two_methyls_on_dimer_base }
            let(:base_specs) { [dept_dimer_base, subject] }
            let(:cut_graph) do
              {
                c1 => [[cr, free_bond]],
                c2 => [[cl, free_bond]],
                cr => [[c1, free_bond]],
                cl => [[c2, free_bond]]
              }
            end
            let(:algorithm_graph) { { cr => [[c1, free_bond]], cl => [[c2, free_bond]] } }
            let(:central_anchors) { [[cl, cr]] }
          end

          shared_examples_for :check_same_graphs do
            it_behaves_like :check_graphs do
              let(:algorithm_graph) { cut_graph }
            end
          end

          it_behaves_like :check_same_graphs do
            subject { dept_right_hydrogenated_bridge }
            let(:base_specs) { [dept_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:cut_graph) { { cr => [] } }
            let(:central_anchors) { [[cr]] }
          end

          it_behaves_like :check_same_graphs do
            subject { dept_activated_bridge }
            let(:base_specs) { [dept_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:cut_graph) { { ct => [] } }
            let(:central_anchors) { [[ct]] }
          end

          it_behaves_like :check_same_graphs do
            subject { dept_activated_methyl_on_bridge }
            let(:base_specs) { [dept_methyl_on_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:cut_graph) { { cm => [] } }
            let(:central_anchors) { [[cm]] }
          end

          it_behaves_like :check_same_graphs do
            subject { dept_activated_methyl_on_incoherent_bridge }
            let(:base_specs) { [dept_methyl_on_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:cut_graph) { { cb => [], cm => [] } }
            let(:central_anchors) { [[cb, cm]] }
          end

          it_behaves_like :check_same_graphs do
            subject { dept_activated_methyl_on_incoherent_bridge }
            let(:specific_specs) { [dept_activated_methyl_on_bridge, subject] }
            let(:cut_graph) { { cb => [] } }
            let(:central_anchors) { [[cb]] }
          end

          it_behaves_like :check_same_graphs do
            subject { dept_activated_dimer }
            let(:base_specs) { [dept_dimer_base] }
            let(:specific_specs) { [subject] }
            let(:cut_graph) { { cr => [] } }
            let(:central_anchors) { [[cr]] }
          end

          it_behaves_like :check_same_graphs do
            subject { dept_methyl_on_dimer_base }
            let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base, subject] }
            let(:cut_graph) do
              { cr => [[cl, bond_100_front]], cl => [[cr, bond_100_front]] }
            end
            let(:central_anchors) { [[cr], [cl]] }
          end

          it_behaves_like :check_same_graphs do
            subject { dept_three_bridges_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_graph) { { ct => [], cc => [] } }
            let(:central_anchors) { [[cc]] }
          end

          describe 'different dept_cross_bridge_on_bridges_base' do
            subject { dept_cross_bridge_on_bridges_base }

            it_behaves_like :check_graphs do
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:cut_graph) do
                {
                  cm => [[ctl, free_bond], [ctr, free_bond]],
                  ctr => [[ctl, position_100_cross], [cm, free_bond]],
                  ctl => [[ctr, position_100_cross], [cm, free_bond]],
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
              let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base, subject] }
              let(:cut_graph) do
                {
                  cm => [],
                  ctr => [[ctl, position_100_cross]],
                  ctl => [[ctr, position_100_cross]],
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

            it_behaves_like :check_graphs do
              let(:base_specs) { [dept_dimer_base, subject] }
              let(:cut_graph) do
                {
                  cm => [[ctl, free_bond], [ctr, free_bond]],
                  ctr => [[ctl, position_100_cross], [cm, free_bond]],
                  ctl => [[ctr, position_100_cross], [cm, free_bond]],
                  csr => [[csl, position_100_cross]],
                  csl => [[csr, position_100_cross]],
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
              let(:base_specs) { [dept_dimer_base, dept_methyl_on_dimer_base, subject] }
              let(:cut_graph) do
                {
                  cm => [],
                  ctr => [[ctl, position_100_cross]],
                  ctl => [[ctr, position_100_cross]],
                  csr => [[csl, position_100_cross]],
                  csl => [[csr, position_100_cross]],
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
