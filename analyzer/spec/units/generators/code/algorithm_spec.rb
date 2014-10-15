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
        let(:essence) { Essence.new(specie) }
        let(:algorithm) { Algorithm.new(specie, essence) }

        [
          :ct, :cr, :cl, :cb, :cm, :cc, :c1, :c2, :ctl, :ctr, :csl, :csr
        ].each do |keyname|
          let(keyname) { subject.spec.atom(keyname) }
        end

        shared_examples_for :check_algorithm do
          it { expect(algorithm.finite_graph).to match_graph(algorithm_graph) }
        end

        it_behaves_like :check_algorithm do
          subject { dept_bridge_base }
          let(:base_specs) { [subject] }
          let(:algorithm_graph) do
            {
              [ct] => [[[cl, cr], param_110_cross]]
            }
          end
        end

        it_behaves_like :check_algorithm do
          subject { dept_methyl_on_bridge_base }
          let(:base_specs) { [dept_bridge_base, subject] }
          let(:algorithm_graph) do
            {
              [cb] => [[[cm], param_amorph]]
            }
          end
        end

        it_behaves_like :check_algorithm do
          subject { dept_vinyl_on_bridge_base }
          let(:base_specs) { [dept_bridge_base, subject] }
          let(:algorithm_graph) do
            {
              [cb] => [[[c1], param_amorph]],
              [c1] => [[[c2], param_amorph]],
            }
          end
        end

        it_behaves_like :check_algorithm do
          subject { dept_dimer_base }
          let(:base_specs) { [dept_bridge_base, subject] }
          let(:algorithm_graph) do
            {
              [cr] => [[[cl], param_100_front]]
            }
          end
        end

        it_behaves_like :check_algorithm do
          subject { dept_two_methyls_on_dimer_base }
          let(:base_specs) { [dept_dimer_base, subject] }
          let(:algorithm_graph) do
            {
              [cr] => [[[c1], param_amorph]],
              [cl] => [[[c2], param_amorph]]
            }
          end
        end

        it_behaves_like :check_algorithm do
          subject { dept_activated_methyl_on_incoherent_bridge }
          let(:base_specs) { [dept_methyl_on_bridge_base] }
          let(:specific_specs) { [subject] }
          let(:algorithm_graph) do
            {
              [cb] => [],
              [cm] => []
            }
          end
        end

        it_behaves_like :check_algorithm do
          subject { dept_methyl_on_dimer_base }
          let(:base_specs) do
            [dept_bridge_base, dept_methyl_on_bridge_base, subject]
          end
          let(:algorithm_graph) do
            {
              [cr] => [[[cl], param_100_front]],
              [cl] => [[[cr], param_100_front]]
            }
          end
        end

        it_behaves_like :check_algorithm do
          subject { dept_three_bridges_base }
          let(:base_specs) { [dept_bridge_base, subject] }
          let(:algorithm_graph) do
            {
              [ct] => [],
              [cc] => []
            }
          end
        end

        it_behaves_like :check_algorithm do
          subject { dept_activated_methyl_on_bridge }
          let(:base_specs) { [dept_methyl_on_bridge_base] }
          let(:specific_specs) { [subject] }
          let(:algorithm_graph) do
            {
              [cm] => []
            }
          end
        end

        it_behaves_like :check_algorithm do
          subject { dept_activated_dimer }
          let(:base_specs) { [dept_dimer_base] }
          let(:specific_specs) { [subject] }
          let(:algorithm_graph) do
            {
              [cr] => []
            }
          end
        end

        describe 'different dept_cross_bridge_on_bridges_base' do
          subject { dept_cross_bridge_on_bridges_base }

          it_behaves_like :check_algorithm do
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:algorithm_graph) do
              {
                [ctl] => [[[cm], param_amorph], [[ctr], param_100_cross]],
                [ctr] => [[[cm], param_amorph]]
              }
            end
          end

          it_behaves_like :check_algorithm do
            let(:base_specs) do
              [dept_bridge_base, dept_methyl_on_bridge_base, subject]
            end
            let(:algorithm_graph) do
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

          it_behaves_like :check_algorithm do
            let(:base_specs) { [dept_dimer_base, subject] }
            let(:algorithm_graph) do
              {
                [csr, ctr] => [[[csl, ctl], param_100_cross]],
                [ctl] => [[[cm], param_amorph]],
                [ctr] => [[[cm], param_amorph]]
              }
            end
          end

          it_behaves_like :check_algorithm do
            let(:base_specs) do
              [dept_dimer_base, dept_methyl_on_dimer_base, subject]
            end
            let(:algorithm_graph) do
              {
                [cm] => [],
                [csr, ctr] => [[[csl, ctl], param_100_cross]],
              }
            end
          end
        end
      end

    end
  end
end
