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

              let(:targets) do
                lateral_chunks.targets.to_a.sort_by do |sa|
                  spec, atom = sa
                  sub_links = lateral_chunks.links.select { |o, _| o == sa }
                  all_rels = sub_links.map(&:last).flat_map { |rels| rels.map(&:last) }
                  dept_spec = generator.specie_class(spec.name).spec
                  dept_atom = dept_spec.spec.atom(spec.keyname(atom))
                  prop = Organizers::AtomProperties.new(dept_spec, dept_atom)
                  [spec.name, prop, all_rels.sort]
                end
              end

              let(:target_specs) { lateral_chunks.target_specs.to_a }
              let(:sidepiece_specs) { lateral_chunks.sidepiece_specs.to_a }
            end

            shared_context :dimer_formation_environment do
              include_context :with_organized_lateral_chunks

              let(:typical_reaction) { dept_dimer_formation }
              let(:t1) { targets.first.last }
              let(:t2) { targets.last.last }

              let(:lateral_dimer) { sidepiece_spec_by_name(:dimer) }
              let_atoms_of(:lateral_dimer, [:cr, :cl], [:d1, :d2])

              let(:lateral_bridge) { (sidepiece_specs - [lateral_dimer]).first }
              let(:b) { lateral_bridge.atom(:ct) }
            end

            shared_examples_for :dimer_formation_in_different_envs do
              include_context :dimer_formation_environment
            end

            shared_context :similar_activated_bridges_environment do
              include_context :with_organized_lateral_chunks

              let(:typical_reaction) { dept_symmetric_dimer_formation }
              let(:t1) { targets.first.last }
              let(:t2) { targets.last.last }

              let(:front_bridge) { sidepiece_spec_related_by(position_100_front) }
              let(:cross_bridge) { sidepiece_spec_related_by(position_100_cross) }

              let(:fb) { front_bridge.atom(:ct) }
              let(:cb) { cross_bridge.atom(:ct) }
            end

            shared_examples_for :many_similar_activated_bridges do
              include_context :similar_activated_bridges_environment
            end

            shared_examples_for :methyl_incorporation_environment do
              include_context :with_organized_lateral_chunks

              let(:typical_reaction) { dept_methyl_incorporation }
              let(:lateral_reactions) { [dept_de_lateral_mi] }

              let(:amob) { (target_specs - [admr]).first }
              let(:admr) do
                target_specs.find { |s| s.name == :'dimer(cr: *)' }
              end

              let(:tm) { amob.atom(:cb) }
              let(:td) { admr.atom(:cl) }

              let(:edge_dimer) { sidepiece_specs.first }

              let_atoms_of(:edge_dimer, [:cl, :cr], [:dm, :dd])
            end

            shared_examples_for :methyl_incorporation_near_edge do
              include_context :methyl_incorporation_environment
            end
          end

        end
      end
    end
  end
end
