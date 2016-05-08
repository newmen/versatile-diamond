module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units
        module Support

          module ReactionUnitExamples
            shared_context :reaction_unit_context do
              include_context :specie_instance_context
              include_context :raw_unique_reactant_context

              let(:typical_reactions) { [dept_reaction] }

              let(:backbone) do
                args = [generator, typical_reaction, anchor_reactant]
                Algorithm::ReactionBackbone.new(*args)
              end
              let(:ordered_graph) { backbone.ordered_graph_from(entry_nodes) }
              let(:entry_nodes) { backbone.entry_nodes.first }

              let(:dict) { Expressions::VarsDictionary.new }
              let(:anchor_reactant) { generator.specie_class(dept_anchor_spec.name) }
              let(:typical_reaction) { generator.reaction_class(dept_reaction.name) }

              # defaults
              let(:node_specie) { entry_nodes.first.uniq_specie }
            end

            shared_context :methyl_adsorbtion_context do
              include_context :reaction_unit_context
              let(:base_specs) { [dept_bridge_base] }
              let(:specific_specs) { [dept_anchor_spec] }
              let(:dept_anchor_spec) { dept_activated_bridge }
              let(:dept_reaction) { dept_methyl_adsorption }
            end

            shared_context :sierpinski_drop_context do
              include_context :reaction_unit_context
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, dept_anchor_spec]
              end
              let(:dept_anchor_spec) { dept_cross_bridge_on_bridges_base }
              let(:dept_reaction) { dept_sierpinski_drop }
            end

            shared_context :dimer_formation_context do
              include_context :reaction_unit_context
              let(:base_specs) { [dept_bridge_base] }
              let(:specific_specs) { [dept_anchor_spec, dept_other_spec] }
              let(:dept_anchor_spec) { dept_activated_incoherent_bridge }
              let(:dept_other_spec) { dept_activated_bridge }
              let(:dept_reaction) { dept_dimer_formation }
            end
          end

        end
      end
    end
  end
end
