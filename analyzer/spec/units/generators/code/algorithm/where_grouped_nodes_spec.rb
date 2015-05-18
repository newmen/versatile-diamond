require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe WhereGroupedNodes, type: :algorithm do
          let(:generator) do
            stub_generator(specific_specs: specific_specs)
          end

          let(:grouped_nodes) { described_class.new(generator, subject) }
          let(:big_links_method) { :links }
          def node_to_vertex(node)
            node.none? ? node.atom : [node.dept_spec.spec, node.atom]
          end

          describe 'parts of dimer row' do
            let(:specific_specs) { [dept_dimer] }
            let(:cl) { dimer.atom(:cl) }
            let(:cr) { dimer.atom(:cr) }
            let(:nodes_list) do
              [
                [Symbol, :one],
                [Symbol, :two]
              ]
            end

            it_behaves_like :check_grouped_nodes_graph do
              subject { WhereLogic.new(generator, at_end) }
              let(:flatten_face_grouped_atoms) { [[:one, :two], [cl, cr]] }
              let(:grouped_graph) do
                {
                  [:one, :two] => [[[cl, cr], param_100_cross]]
                }
              end
            end

            it_behaves_like :check_grouped_nodes_graph do
              subject { WhereLogic.new(generator, at_middle) }
              let(:cl_dup) { dimer_dup.atom(:cl) }
              let(:cr_dup) { dimer_dup.atom(:cr) }

              let(:flatten_face_grouped_atoms) do
                [[:one, :two], [cl, cr], [cl_dup, cr_dup]]
              end
              let(:grouped_graph) do
                {
                  [:one, :two] => [
                    [[cl, cr], param_100_cross], [[cl_dup, cr_dup], param_100_cross]
                  ]
                }
              end
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { WhereLogic.new(generator, near_methyl) }
            let(:specific_specs) { [dept_methyl_on_bridge] }
            let(:cb) { methyl_on_bridge.atom(:cb) }

            let(:flatten_face_grouped_atoms) { [[:target, cb]] }
            let(:nodes_list) do
              [
                [Symbol, :target]
              ]
            end
            let(:grouped_graph) do
              {
                [:target] => [[[cb], param_100_front]]
              }
            end
          end
        end

      end
    end
  end
end
