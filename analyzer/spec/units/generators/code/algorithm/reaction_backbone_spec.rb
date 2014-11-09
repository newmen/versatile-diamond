require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ReactionBackbone, type: :algorithm do
          let(:base_specs) { [] }
          let(:generator) do
            stub_generator(base_specs: base_specs, typical_reactions: [subject])
          end

          let(:reaction) { generator.reaction_class(subject.name) }
          let(:specie) { generator.specie_class(spec.name) }
          let(:backbone) { described_class.new(generator, reaction, specie) }

          describe '#final_graph' do
            describe 'without relations' do
              let(:final_graph) { {} }

              it_behaves_like :check_finite_graph do
                subject { dept_methyl_activation }
                let(:spec) { methyl_on_bridge_base }
              end

              it_behaves_like :check_finite_graph do
                subject { dept_methyl_desorption }
                let(:spec) { activated_methyl_on_bridge }
              end

              it_behaves_like :check_finite_graph do
                subject { dept_sierpinski_drop }
                let(:spec) { cross_bridge_on_bridges_base }
              end
            end

            describe 'in both directions with one relation' do
              subject { dept_dimer_formation }
              let(:a1) { activated_bridge.atom(:ct) }
              let(:a2) { activated_incoherent_bridge.atom(:ct) }

              it_behaves_like :check_finite_graph do
                let(:spec) { activated_bridge }
                let(:final_graph) do
                  {
                    [a1] => [[[a2], param_100_front]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:spec) { activated_incoherent_bridge }
                let(:final_graph) do
                  {
                    [a2] => [[[a1], param_100_front]]
                  }
                end
              end
            end

            describe 'in both directions with many relation' do
              subject { dept_methyl_incorporation }
              let(:am1) { activated_methyl_on_bridge.atom(:cr) }
              let(:am2) { activated_methyl_on_bridge.atom(:cl) }
              let(:ad1) { activated_dimer.atom(:cr) }
              let(:ad2) { activated_dimer.atom(:cl) }

              it_behaves_like :check_finite_graph do
                let(:spec) { activated_methyl_on_bridge }
                let(:final_graph) do
                  {
                    [am1, am2] => [[[ad2, ad1], param_100_cross]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:base_specs) { [dept_bridge_base] }
                let(:spec) { activated_dimer }
                let(:amb) { activated_methyl_on_bridge.atom(:cb) }
                let(:amm) { activated_methyl_on_bridge.atom(:cm) }
                let(:final_graph) do
                  {
                    [ad2, ad1] => [[[am1, am2], param_100_cross]],
                    [am1, am2] => [[[amb], param_110_front]],
                    [amb] => [[[amm], param_amorph]]
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
