require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe WhereBackbone, type: :algorithm do
          let(:generator) do
            stub_generator(specific_specs: specific_specs)
          end

          let(:backbone) { described_class.new(generator, subject) }

          describe '#final_graph' do
            it_behaves_like :check_finite_graph do
              subject { WhereLogic.new(generator, at_end) }
              let(:specific_specs) { [dept_dimer] }
              let(:final_graph) do
                {
                  [:one, :two] => [
                    [[dimer.atom(:cl), dimer.atom(:cr)], param_100_cross]
                  ]
                }
              end
            end

            it_behaves_like :check_finite_graph do
              subject { WhereLogic.new(generator, at_middle) }
              let(:specific_specs) { [dept_dimer] }
              let(:final_graph) do
                {
                  [:one, :two] => [
                    [[dimer.atom(:cl), dimer.atom(:cr)], param_100_cross],
                    [[dimer_dup.atom(:cl), dimer_dup.atom(:cr)], param_100_cross]
                  ]
                }
              end
            end

            it_behaves_like :check_finite_graph do
              subject { WhereLogic.new(generator, near_methyl) }
              let(:specific_specs) { [dept_methyl_on_bridge] }
              let(:final_graph) do
                {
                  [:target] => [[[methyl_on_bridge.atom(:cb)], param_100_front]]
                }
              end
            end
          end

          describe '#entry_nodes' do
            describe 'parts of dimer row' do
              let(:specific_specs) { [dept_dimer] }
              let(:points_list) { [[:one, :two]] }

              it_behaves_like :check_entry_nodes do
                subject { WhereLogic.new(generator, at_end) }
              end

              it_behaves_like :check_entry_nodes do
                subject { WhereLogic.new(generator, at_middle) }
              end
            end

            it_behaves_like :check_entry_nodes do
              subject { WhereLogic.new(generator, near_methyl) }
              let(:specific_specs) { [dept_methyl_on_bridge] }
              let(:points_list) { [[:target]] }
            end
          end

          describe '#ordered_graph_from' do
            it_behaves_like :check_ordered_graph do
              subject { WhereLogic.new(generator, at_end) }
              let(:specific_specs) { [dept_dimer] }
              let(:ordered_graph) do
                [[
                  [:one, :two],
                  [[[dimer.atom(:cl), dimer.atom(:cr)], param_100_cross]]
                ]]
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { WhereLogic.new(generator, at_middle) }
              let(:specific_specs) { [dept_dimer] }
              let(:ordered_graph) do
                [
                  [[:two], [
                    [[dimer.atom(:cr), dimer_dup.atom(:cr)], param_100_cross]]
                  ],
                  [[:one], [
                    [[dimer.atom(:cl), dimer_dup.atom(:cl)], param_100_cross]]
                  ]
                ]
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { WhereLogic.new(generator, near_methyl) }
              let(:specific_specs) { [dept_methyl_on_bridge] }
              let(:ordered_graph) do
                [
                  [[:target], [[[methyl_on_bridge.atom(:cb)], param_100_front]]]
                ]
              end
            end
          end
        end

      end
    end
  end
end
