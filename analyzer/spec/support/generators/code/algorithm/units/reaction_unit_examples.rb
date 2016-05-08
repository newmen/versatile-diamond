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
              let(:nbr_nodes) { ordered_graph.first.last.first.first }
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

              let(:amorph_nodes) { entry_nodes.reject(&:lattice) }
              let(:lattice_nodes) { entry_nodes.select(&:lattice) }
            end

            shared_context :sierpinski_formation_context do
              include_context :reaction_unit_context
              let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
              let(:specific_specs) { [dept_anchor_spec, dept_other_spec] }
              let(:dept_anchor_spec) { dept_activated_bridge }
              let(:dept_other_spec) { dept_activated_methyl_on_bridge }
              let(:dept_reaction) { dept_sierpinski_formation }

              let(:amorph_nodes) { ordered_graph.last.last.first.first }
            end

            shared_context :dimer_formation_context do
              include_context :reaction_unit_context
              let(:base_specs) { [dept_bridge_base] }
              let(:specific_specs) { [dept_anchor_spec, dept_other_spec] }
              let(:dept_anchor_spec) { dept_activated_incoherent_bridge }
              let(:dept_other_spec) { dept_activated_bridge }
              let(:dept_reaction) { dept_dimer_formation }
            end

            shared_context :intermed_migr_dh_formation_context do
              include_context :reaction_unit_context
              let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
              let(:specific_specs) { [dept_anchor_spec, dept_other_spec] }
              let(:dept_anchor_spec) { dept_activated_bridge }
              let(:dept_other_spec) { dept_activated_methyl_on_dimer }
              let(:dept_reaction) { dept_intermed_migr_dh_formation }

              let(:amod) { (dept_reaction.source - [ab]).first }
              let(:ab) do
                dept_reaction.source.find { |s| s.name == dept_anchor_spec.spec.name }
              end

              let_atoms_of(:ab, [:cr, :cl], [:cbr, :cbl])
              let_atoms_of(:amod, [:cr, :cl], [:cdr, :cdl])
            end

            shared_context :intermed_migr_df_formation_context do
              include_context :intermed_migr_dh_formation_context
              let(:dept_reaction) { dept_intermed_migr_df_formation } # override
            end

            shared_context :alt_intermed_migr_df_formation_context do
              include_context :intermed_migr_df_formation_context
              let(:dept_anchor_spec) { dept_activated_methyl_on_dimer } # override
              let(:dept_other_spec) { dept_activated_bridge } # override

              let(:ab) do # override
                dept_reaction.source.find { |s| s.name == dept_other_spec.spec.name }
              end
            end

            shared_context :two_next_dimers_formation_context do
              include_context :reaction_unit_context
              let(:base_specs) do
                [
                  dept_bridge_base,
                  dept_dimer_base,
                  dept_methyl_on_bridge_base,
                  dept_dimer_near_mob_base
                ]
              end
              let(:specific_specs) { [dept_anchor_spec, dept_other_spec] }
              let(:dept_anchor_spec) { dept_ea_dimer_near_ea_mob }
              let(:dept_other_spec) { dept_activated_bridge }
              let(:dept_reaction) { dept_two_next_dimers_formation }

              let(:bone_dimer_nodes) { ordered_graph.last.first }

              let(:ead_n_eamob) { (dept_reaction.source - [ab]).first }
              let(:ab) do
                dept_reaction.source.find { |s| s.name == dept_other_spec.spec.name }
              end

              let_atoms_of(:ead_n_eamob, [:cdr, :cdd])
              let_atoms_of(:ab, [:ct], [:cbt])
            end
          end

        end
      end
    end
  end
end
