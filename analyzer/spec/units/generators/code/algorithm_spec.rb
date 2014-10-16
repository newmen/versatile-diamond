require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Algorithm, use: :engine_generator do
        let(:base_specs) { [] }
        let(:specific_specs) { [] }
        let(:generator) do
          stub_generator(base_specs: base_specs, specific_specs: specific_specs)
        end

        let(:specie) { generator.specie_class(subject.name) }
        let(:algorithm) { Algorithm.new(specie) }

        [
          :ct, :cr, :cl, :cb, :cm, :cc, :c1, :c2, :ctl, :ctr, :csl, :csr
        ].each do |keyname|
          let(keyname) { subject.spec.atom(keyname) }
        end

        describe '#finite_graph' do
          shared_examples_for :check_finite_graph do
            it { expect(algorithm.finite_graph).to match_graph(finite_graph) }
          end

          it_behaves_like :check_finite_graph do
            subject { dept_bridge_base }
            let(:base_specs) { [subject] }
            let(:finite_graph) do
              {
                [ct] => [[[cl, cr], param_110_cross]]
              }
            end
          end

          it_behaves_like :check_finite_graph do
            subject { dept_methyl_on_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:finite_graph) do
              {
                [cb] => [[[cm], param_amorph]]
              }
            end
          end

          it_behaves_like :check_finite_graph do
            subject { dept_vinyl_on_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:finite_graph) do
              {
                [cb] => [[[c1], param_amorph]],
                [c1] => [[[c2], param_amorph]],
              }
            end
          end

          it_behaves_like :check_finite_graph do
            subject { dept_dimer_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:finite_graph) do
              {
                [cr] => [[[cl], param_100_front]]
              }
            end
          end

          it_behaves_like :check_finite_graph do
            subject { dept_two_methyls_on_dimer_base }
            let(:base_specs) { [dept_dimer_base, subject] }
            let(:finite_graph) do
              {
                [cr] => [[[c1], param_amorph]],
                [cl] => [[[c2], param_amorph]]
              }
            end
          end

          it_behaves_like :check_finite_graph do
            subject { dept_activated_methyl_on_incoherent_bridge }
            let(:base_specs) { [dept_methyl_on_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:finite_graph) do
              {
                [cb] => [],
                [cm] => []
              }
            end
          end

          it_behaves_like :check_finite_graph do
            subject { dept_methyl_on_dimer_base }
            let(:base_specs) do
              [dept_bridge_base, dept_methyl_on_bridge_base, subject]
            end
            let(:finite_graph) do
              {
                [cr] => [[[cl], param_100_front]],
                [cl] => [[[cr], param_100_front]]
              }
            end
          end

          it_behaves_like :check_finite_graph do
            subject { dept_three_bridges_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:finite_graph) do
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
            let(:finite_graph) do
              {
                [cr] => []
              }
            end
          end

          describe 'different dept_cross_bridge_on_bridges_base' do
            subject { dept_cross_bridge_on_bridges_base }

            it_behaves_like :check_finite_graph do
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:finite_graph) do
                {
                  [ctl] => [[[cm], param_amorph], [[ctr], param_100_cross]],
                  [ctr] => [[[cm], param_amorph]]
                }
              end
            end

            it_behaves_like :check_finite_graph do
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:finite_graph) do
                {
                  [cm] => [],
                  [ctl] => [[[ctr], param_100_cross]]
                }
              end
            end
          end

          describe 'different dept_cross_bridge_on_dimers_base' do
            subject { dept_cross_bridge_on_dimers_base }
            let(:face_grouped_anchors) { [[ctr, csr], [ctl, csl], [cm]] }

            it_behaves_like :check_finite_graph do
              let(:base_specs) { [dept_dimer_base, subject] }
              let(:finite_graph) do
                {
                  [csr, ctr] => [[[csl, ctl], param_100_cross]],
                  [ctl] => [[[cm], param_amorph]],
                  [ctr] => [[[cm], param_amorph]]
                }
              end
            end

            it_behaves_like :check_finite_graph do
              let(:base_specs) do
                [dept_dimer_base, dept_methyl_on_dimer_base, subject]
              end
              let(:finite_graph) do
                {
                  [cm] => [],
                  [csr, ctr] => [[[csl, ctl], param_100_cross]],
                }
              end
            end
          end
        end

        describe '#ordered_graph_from' do
          shared_examples_for :check_ordered_graph do
            it { expect(algorithm.ordered_graph_from(anchors)).to eq(ordered_graph) }
          end

          it_behaves_like :check_ordered_graph do
            subject { dept_bridge_base }
            let(:base_specs) { [subject] }
            let(:anchors) { [ct] }
            let(:ordered_graph) do
              [
                [[ct], [[[cl, cr], param_110_cross]]]
              ]
            end
          end

          it_behaves_like :check_ordered_graph do
            subject { dept_vinyl_on_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:anchors) { [cb] }
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
            let(:anchors) { [cr] }
            let(:ordered_graph) do
              [
                [[cr], [[[cl], param_100_front]]]
              ]
            end
          end

          it_behaves_like :check_ordered_graph do
            subject { dept_two_methyls_on_dimer_base }
            let(:base_specs) { [dept_dimer_base, subject] }
            let(:anchors) { [cr, cl] }
            let(:ordered_graph) do
              [
                [[cr], [[[c1], param_amorph]]],
                [[cl], [[[c2], param_amorph]]]
              ]
            end
          end

          it_behaves_like :check_ordered_graph do
            subject { dept_activated_methyl_on_incoherent_bridge }
            let(:base_specs) { [dept_methyl_on_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:anchors) { [cb, cm] }
            let(:ordered_graph) do
              [
                [[cb], []],
                [[cm], []]
              ]
            end
          end

          it_behaves_like :check_ordered_graph do
            subject { dept_three_bridges_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:anchors) { [cc] }
            let(:ordered_graph) do
              [
                [[cc], []],
                [[ct], []]
              ]
            end
          end

          it_behaves_like :check_ordered_graph do
            subject { dept_cross_bridge_on_bridges_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:anchors) { [ctl] }
            let(:ordered_graph) do
              [
                [[ctl], [[[cm], param_amorph], [[ctr], param_100_cross]]],
                [[ctr], [[[cm], param_amorph]]]
              ]
            end
          end

          describe 'different anchors' do
            subject { dept_methyl_on_dimer_base }
            let(:base_specs) do
              [dept_bridge_base, dept_methyl_on_bridge_base, subject]
            end

            it_behaves_like :check_ordered_graph do
              let(:anchors) { [cr] }
              let(:ordered_graph) do
                [
                  [[cr], [[[cl], param_100_front]]]
                ]
              end
            end

            it_behaves_like :check_ordered_graph do
              let(:anchors) { [cl] }
              let(:ordered_graph) do
                [
                  [[cl], [[[cr], param_100_front]]]
                ]
              end
            end
          end
        end
      end

    end
  end
end
