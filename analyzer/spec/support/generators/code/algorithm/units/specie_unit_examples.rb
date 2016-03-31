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
              let(:entry_nodes) { backbone.entry_nodes.first }
              let(:ordered_graph) { backbone.ordered_graph_from(entry_nodes) }

              let(:dict) { Expressions::VarsDictionary.new }
              let(:original_specie) { generator.specie_class(dept_uniq_specie.name) }

              # defaults
              let(:unit_nodes) { entry_nodes }
              let(:node_specie) { entry_nodes.first.uniq_specie }
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

            shared_context :two_mobs_context do
              include_context :specie_unit_context
              let(:base_specs) { [dept_bridge_base, dept_uniq_specie] }
              let(:typical_reactions) { [dept_sierpinski_drop] }

              let(:unit_nodes) { entry_nodes.first.split } # override

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
              let(:typical_reactions) { [dept_intermed_migr_dc_drop] }

              let(:entry_nodes) do # override
                backbone.entry_nodes.reject { |ns| ns.first.atom.lattice }.first
              end
              let(:dept_uniq_specie) { dept_intermed_migr_down_common_base }

              [:cbl, :cbr, :cdl, :cdr].each do |keyname|
                let(keyname) { dept_uniq_specie.spec.atom(keyname) }
              end
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
              let(:typical_reactions) { [dept_intermed_migr_dh_drop] }
              let(:unit_nodes) { ordered_graph.last.last.first.first }
              let(:dept_uniq_specie) { dept_intermed_migr_down_half_base }
            end

            shared_context :tree_bridges_context do
              include_context :specie_unit_context
              let(:base_specs) { [dept_bridge_base, dept_uniq_specie] }
              let(:dept_uniq_specie) { dept_three_bridges_base }
              let(:unit_nodes) { backbone.entry_nodes.first.first.split } # override
            end

            shared_context :bridged_bwd_context do
              include_context :specie_unit_context
              let(:base_specs) { [dept_bridge_base, dept_uniq_specie] }
              let(:dept_uniq_specie) { dept_bridge_with_dimer_base }
              let(:unit_nodes) { backbone.entry_nodes.first.first.split } # override
            end

            shared_context :bwd_context do
              include_context :bridged_bwd_context
              let(:base_specs) do
                [dept_bridge_base, dept_dimer_base, dept_uniq_specie]
              end
            end
          end

        end
      end
    end
  end
end
