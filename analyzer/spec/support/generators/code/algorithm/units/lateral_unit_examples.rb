module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units
        module Support

          module LateralUnitExamples
            include Code::SpeciesUser

            shared_context :lateral_unit_common_context do
              let(:ordered_graph) { backbone.ordered_graph_from(entry_nodes) }
              let(:entry_nodes) { backbone.entry_nodes.first }
              let(:action_nodes) { backbone.action_nodes }
              let(:side_nodes) do
                values = ordered_graph.map(&:last)
                values.flat_map { |rels| rels.flat_map(&:first) }.uniq
              end

              let(:dict) { Expressions::LateralExprsDictionary.new(action_nodes) }

              let(:target_species) { entry_nodes.map(&:uniq_specie).uniq }
              let(:sidepiece_species) { side_nodes.map(&:uniq_specie).uniq }

              let(:first_ts) { target_species.first }
              let(:last_ts) { target_species.last }
            end

            shared_context :look_around_context do
              include_context :lateral_unit_common_context
              let(:backbone) do
                Algorithm::LookAroundBackbone.new(generator, lateral_chunks)
              end
            end

            shared_context :check_laterals_context do
              include_context :lateral_unit_common_context
              let(:specie) { specie_class(spec) }
              let(:backbone) do
                Algorithm::CheckLateralsBackbone.new(generator, lateral_chunks, specie)
              end
            end

            shared_context :end_dimer_formation_lateral_context do
              include_context :dimer_formation_environment
              let(:lateral_reactions) { [dept_end_lateral_df] }
            end

            shared_context :small_activated_bridges_lateral_context do
              include_context :similar_activated_bridges_environment
              let(:lateral_reactions) { [dept_small_ab_lateral_sdf] }
            end
          end

        end
      end
    end
  end
end
