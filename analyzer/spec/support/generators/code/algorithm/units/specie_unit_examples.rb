module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units
        module Support

          module SpecieUnitExamples
            shared_context :specie_unit_context do
              include_context :specie_instance_context
              include_context :raw_unique_parent_context

              let(:backbone) do
                Algorithm::SpecieBackbone.new(generator, original_specie)
              end
              let(:ordered_graph) { backbone.ordered_graph_from(entry_nodes) }
              let(:entry_nodes) { backbone.entry_nodes.first }
              let(:splitable_nodes) { backbone.entry_nodes - not_splitable_nodes }
              let(:not_splitable_nodes) do
                backbone.entry_nodes.reject { |ns| ns.any?(&:splittable?) }
              end

              let(:dict) { Expressions::VarsDictionary.new }
              let(:original_specie) { generator.specie_class(dept_uniq_specie.name) }

              # defaults
              let(:unit_nodes) { entry_nodes.flat_map(&:split) }
              let(:node_specie) { entry_nodes.first.uniq_specie }

              # abstract
              let(:unit_species) { unit_nodes.map(&:uniq_specie) }
              let(:nodes_species) { nodes.map(&:uniq_specie) }
              let(:nodes_atoms) { nodes.map(&:atom) }
            end

            shared_context :bridge_context do
              include_context :specie_unit_context
              let(:base_specs) { [dept_uniq_specie] }
              let(:typical_reactions) { [dept_dimer_formation] }

              let(:dept_uniq_specie) { dept_bridge_base }
            end

            shared_context :alt_bridge_context do
              include_context :bridge_context
              let(:unit_nodes) do # override
                ordered_graph.first.last.first.first
              end
            end

            shared_context :rab_context do
              include_context :specie_unit_context
              let(:base_specs) { [dept_bridge_base] }
              let(:specific_specs) { [dept_uniq_specie] }
              let(:typical_reactions) { [dept_hydrogen_abs_from_gap] }

              let(:dept_uniq_specie) { dept_right_hydrogenated_bridge }
            end

            shared_context :mob_context do
              include_context :specie_unit_context
              let(:base_specs) { [dept_bridge_base, dept_uniq_specie] }

              let(:dept_uniq_specie) { dept_methyl_on_bridge_base }
            end

            shared_context :incoherent_dimer_context do
              include_context :specie_unit_context
              let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
              let(:specific_specs) { [dept_uniq_specie] }
              let(:typical_reactions) { [dept_incoherent_dimer_drop] }

              let(:dept_uniq_specie) { dept_twise_incoherent_dimer }
            end

            shared_context :two_mobs_context do
              include_context :specie_unit_context
              let(:base_specs) { [dept_bridge_base, dept_uniq_specie] }
              let(:typical_reactions) { [dept_sierpinski_drop] }

              let(:dept_uniq_specie) { dept_cross_bridge_on_bridges_base }
              let(:cbs_relation) { ordered_graph.last }
              let(:node_specie) { cbs_relation.first.first.uniq_specie }
              let(:nbr_specie) { cbs_relation.last.first.first.first.uniq_specie }
              let(:scope_specie) { entry_nodes.first.uniq_specie }
              let(:uniq_parents) { unit_nodes.map(&:uniq_specie) }
            end

            shared_context :alt_two_mobs_context do
              include_context :two_mobs_context
              let(:unit_nodes) do # override
                [
                  cbs_relation.first.first,
                  cbs_relation.last.first.first.first
                ]
              end
            end

            shared_context :intermed_context do
              include_context :specie_unit_context
              let(:base_specs) do
                [
                  dept_bridge_base,
                  dept_methyl_on_bridge_base,
                  dept_methyl_on_dimer_base,
                  dept_uniq_specie
                ]
              end
              let(:typical_reactions) { [dept_migration_over_111] }

              let(:entry_nodes) { amorph_nodes } # override
              let(:amorph_nodes) do
                backbone.entry_nodes.reject { |ns| ns.first.atom.lattice }.first
              end
              let(:not_entry_nodes) do
                (ordered_graph.map(&:first) - backbone.entry_nodes).first
              end
              let(:dept_uniq_specie) { dept_intermed_migr_down_common_base }

              let_atoms_of(:'dept_uniq_specie.spec', [:cbl, :cbr, :cdl, :cdr])
            end

            shared_context :alt_intermed_context do
              include_context :intermed_context
              let(:entry_nodes) { anchored_latticed_nodes.first } # override
              let(:anchored_latticed_nodes) do
                backbone.entry_nodes.select do |nodes|
                  nodes.first.atom.lattice && nodes.all?(&:anchor?)
                end
              end
            end

            shared_context :half_intermed_context do
              include_context :alt_intermed_context
              let(:unit_nodes) { ordered_graph.last.last.first.first }
              let(:dept_uniq_specie) { dept_intermed_migr_down_half_base }
            end

            shared_context :alt_half_intermed_context do
              include_context :half_intermed_context
              let(:entry_nodes) { amorph_nodes } # override
            end

            shared_context :tree_bridges_context do
              include_context :specie_unit_context
              let(:base_specs) { [dept_bridge_base, dept_uniq_specie] }
              let(:dept_uniq_specie) { dept_three_bridges_base }
            end

            shared_context :bridged_bwd_context do
              include_context :specie_unit_context
              let(:base_specs) { [dept_bridge_base, dept_uniq_specie] }
              let(:dept_uniq_specie) { dept_bridge_with_dimer_base }
            end

            shared_context :bwd_context do
              include_context :bridged_bwd_context
              let(:base_specs) do
                [dept_bridge_base, dept_dimer_base, dept_uniq_specie]
              end
            end

            shared_context :top_mob_context do
              include_context :specie_unit_context
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, dept_uniq_specie]
              end
              let(:typical_reactions) { [dept_migration_over_111] }
              let(:dept_uniq_specie) { dept_top_methyl_on_half_extended_bridge_base }
              let(:entry_nodes) { not_splitable_nodes.first } # override
            end

            shared_context :alt_top_mob_context do
              include_context :top_mob_context
              let(:entry_nodes) { splitable_nodes.first } # override
            end

            shared_context :bottom_mob_context do
              include_context :specie_unit_context
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_right_bridge_base, dept_uniq_specie]
              end
              let(:typical_reactions) { [dept_reverse_migration_over_111] }
              let(:dept_uniq_specie) { dept_lower_methyl_on_half_extended_bridge_base }
              let(:entry_nodes) { splitable_nodes.first } # override
            end
          end

        end
      end
    end
  end
end
