module VersatileDiamond
  module Generators
    module Code
      module Algorithm
        module Support

          module LateralEnvironmentsExamples
            shared_context :with_organized_lateral_chunks do
              let(:generator) do
                stub_generator(
                  typical_reactions: [typical_reaction],
                  lateral_reactions: lateral_reactions
                )
              end

              let(:reaction) { generator.reaction_class(typical_reaction.name) }
              let(:lateral_chunks) { reaction.lateral_chunks }

              let(:target_specs) { lateral_chunks.target_specs.to_a }
              let(:sidepiece_specs) { lateral_chunks.sidepiece_specs.to_a }
            end

            shared_examples_for :dimer_formation_in_different_envs do
              include_context :with_organized_lateral_chunks

              let(:typical_reaction) { dept_dimer_formation }
              let(:t1) { target_specs.first.atom(:ct) }
              let(:t2) { target_specs.last.atom(:ct) }

              let(:lateral_dimer) { sidepiece_spec_by_name(:dimer) }
              let(:d1) { lateral_dimer.atom(:cr) }
              let(:d2) { lateral_dimer.atom(:cl) }

              let(:lateral_bridge) { (sidepiece_specs - [lateral_dimer]).first }
              let(:b) { lateral_bridge.atom(:ct) }
            end

            shared_examples_for :many_similar_activated_bridges do
              include_context :with_organized_lateral_chunks

              let(:typical_reaction) { dept_symmetric_dimer_formation }
              let(:t1) { target_specs.first.atom(:ct) }

              let(:front_bridge) { sidepiece_spec_related_by(position_100_front) }
              let(:cross_bridge) { sidepiece_spec_related_by(position_100_cross) }

              let(:fb) { front_bridge.atom(:ct) }
              let(:cb) { cross_bridge.atom(:ct) }
            end
          end

        end
      end
    end
  end
end
