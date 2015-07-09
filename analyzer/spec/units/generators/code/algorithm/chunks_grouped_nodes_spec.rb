require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ChunksGroupedNodes, type: :algorithm do
          let(:generator) do
            stub_generator(
              typical_reactions: [dependent_typical_reaction],
              lateral_reactions: dependent_lateral_reactions
            )
          end
          let(:reaction) { generator.reaction_class(dependent_typical_reaction.name) }
          let(:chunks) { dependent_lateral_reactions.map(&:chunk) }
          let(:grouped_nodes) { described_class.new(generator, subject) }
          subject { reaction.lateral_chunks }

          let(:big_links_method) { :total_links }
          def node_to_vertex(node); [node.dept_spec.spec, node.atom] end

          it_behaves_like :check_grouped_nodes_graph do
            let(:dependent_typical_reaction) { dept_dimer_formation }
            let(:dependent_lateral_reactions) { [dept_end_lateral_df] }
            let(:sidepiece_specs) { subject.sidepiece_specs.to_a }

            let(:t1) { df_source.first.atom(:ct) }
            let(:t2) { df_source.last.atom(:ct) }

            let(:first_lateral_dimer) { sidepiece_specs.first }
            let(:df1) { first_lateral_dimer.atom(:cr) }
            let(:df2) { first_lateral_dimer.atom(:cl) }

            let(:second_lateral_dimer) { sidepiece_specs.last }
            let(:ds1) { second_lateral_dimer.atom(:cr) }
            let(:ds2) { second_lateral_dimer.atom(:cl) }

            let(:flatten_face_grouped_atoms) { [[t1, t2], [df1, df2], [ds1, ds2]] }
            let(:nodes_list) do
              [
                [UniqueSpecie, t1],
                [UniqueSpecie, t2],
                [UniqueSpecie, df1],
                [UniqueSpecie, df2],
                [UniqueSpecie, ds1],
                [UniqueSpecie, ds2]
              ]
            end
            let(:grouped_graph) do
              {
                [t1, t2] => [
                  [[df2, df1], param_100_cross], [[ds2, ds1], param_100_cross]
                ],
                [df1, df2] => [[[t2, t1], param_100_cross]],
                [ds1, ds2] => [[[t2, t1], param_100_cross]]
              }
            end
          end
        end

      end
    end
  end
end
