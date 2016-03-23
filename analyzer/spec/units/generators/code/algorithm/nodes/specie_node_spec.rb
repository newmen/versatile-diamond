require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        describe SpecieNode, type: :algorithm do
          let(:base_specs) { [dept_bridge_base, dept_mob, dept_three_bridges_base] }
          let(:specific_specs) { [] }
          let(:typical_reactions) { [] }
          let(:generator) do
            stub_generator(base_specs: base_specs,
                           specific_specs: specific_specs,
                           typical_reactions: typical_reactions)
          end
          let(:bridge) { generator.specie_class(bridge_base.name) }

          let(:factory_mob) { Algorithm::SpecieNodesFactory.new(generator, code_mob) }
          let(:code_mob) { generator.specie_class(dept_mob.name) }
          let(:dept_mob) { dept_methyl_on_bridge_base }

          [:cm, :cb, :cr].each do |keyname|
            let(keyname) { dept_mob.spec.atom(keyname) }
            let(:"node_#{keyname}") { factory_mob.get_node(send(keyname)) }
          end

          let(:cc) { three_bridges_base.atom(:cc) }
          let(:node_cc) do
            code_tbs = generator.specie_class(dept_three_bridges_base.name)
            factory_tbs = Algorithm::SpecieNodesFactory.new(generator, code_tbs)
            factory_tbs.get_node(cc)
          end

          describe '#none?' do
            it { expect(node_cm.none?).to be_truthy }
            it { expect(node_cb.none?).to be_falsey }
            it { expect(node_cc.none?).to be_falsey }
          end

          describe '#scope?' do
            it { expect(node_cm.scope?).to be_falsey }
            it { expect(node_cb.scope?).to be_falsey }
            it { expect(node_cc.scope?).to be_truthy }
          end

          describe '#uniq_specie' do
            it { expect(node_cm.uniq_specie.original).to eq(code_mob) }
            it { expect(node_cm.uniq_specie).
              to be_a(Algorithm::Instances::NoneSpecie) }

            it { expect(node_cb.uniq_specie.original).to eq(bridge) }
            it { expect(node_cb.uniq_specie).
              to be_a(Algorithm::Instances::UniqueParent) }

            let(:original_species) { node_cc.uniq_specie.species.map(&:original).uniq }
            it { expect(original_species).to eq([bridge]) }
            it { expect(node_cc.uniq_specie).
              to be_a(Algorithm::Instances::SpeciesScope) }
          end

          describe '#spec' do
            it { expect(node_cm.spec).to eq(dept_mob) }
            it { expect(node_cb.spec).not_to eq(dept_bridge_base) }
            it { expect(node_cb.spec.original).to eq(dept_bridge_base) }
          end

          describe '#anchor?' do
            it { expect(node_cm.anchor?).to be_truthy }
            it { expect(node_cb.anchor?).to be_truthy } # because for bridge
            it { expect(node_cc.anchor?).to be_truthy }
          end

          describe '#used_many_times?' do
            it { expect(node_cm.used_many_times?).to be_falsey }
            it { expect(node_cb.used_many_times?).to be_falsey }
            it { expect(node_cc.used_many_times?).to be_falsey }
            it { expect(node_cr.used_many_times?).to be_truthy }
          end

          describe '#usages_num' do
            it { expect(node_cm.usages_num).to eq(1) }
            it { expect(node_cb.usages_num).to eq(1) }
            it { expect(node_cc.usages_num).to eq(1) }
            it { expect(node_cr.usages_num).to eq(2) }
          end

          describe '#lattice' do
            it { expect(node_cm.lattice).to be_nil }
            it { expect(node_cb.lattice).to eq(cb.lattice) }
            it { expect(node_cc.lattice).to eq(node_cb.lattice) }
          end

          describe '#relations_limits' do
            it { expect(node_cm.relations_limits).to be_a(Hash) }
            it { expect(node_cb.relations_limits).to be_a(Hash) }
            it { expect(node_cc.relations_limits).to eq(node_cb.relations_limits) }
            it { expect(node_cc.relations_limits).not_to eq(node_cm.relations_limits) }
          end

          describe '#<=>' do
            it { expect(node_cm <=> node_cb).to eq(1) }
            it { expect(node_cb <=> node_cm).to eq(-1) }
            it { expect(node_cr <=> node_cb).to eq(1) }
            it { expect(node_cb <=> node_cr).to eq(-1) }
            it { expect(node_cb <=> node_cc).to eq(1) }
            it { expect(node_cc <=> node_cb).to eq(-1) }
          end

          describe '#properties' do
            let(:props_cm) { Organizers::AtomProperties.new(dept_mob, cm) }
            it { expect(node_cm.properties).to eq(props_cm) }

            let(:props_cb) { Organizers::AtomProperties.new(dept_mob, cb) }
            it { expect(node_cb.properties).to eq(props_cb) }

            let(:props_cc) do
              Organizers::AtomProperties.new(dept_three_bridges_base, cc)
            end
            it { expect(node_cc.properties).to eq(props_cc) }
          end

          describe '#sub_properties' do
            let(:ct) { dept_bridge_base.spec.atom(:ct) }
            let(:props_ct) { Organizers::AtomProperties.new(dept_bridge_base, ct) }
            it { expect(node_cb.sub_properties).to eq(props_ct) }
          end

          describe '#symmetric_atoms' do
            it { expect(node_cm.symmetric_atoms).to be_empty }
            it { expect(node_cb.symmetric_atoms).to be_empty }
            it { expect(node_cr.symmetric_atoms).to be_empty }

            describe 'in symmetric specie' do
              let(:base_specs) { [dept_bridge_base] }
              let(:specific_specs) { [dept_right_hydrogenated_bridge] }
              let(:typical_reactions) { [dept_hydrogen_abs_from_gap] }

              let(:factory_rab) do
                Algorithm::SpecieNodesFactory.new(generator, code_rab)
              end
              let(:code_rab) { generator.specie_class(right_hydrogenated_bridge.name) }

              let(:cr) { right_hydrogenated_bridge.atom(:cr) }
              let(:cl) { right_hydrogenated_bridge.atom(:cl) }
              let(:node_cr) { factory_rab.get_node(cr) }

              it { expect(node_cr.symmetric_atoms).to match_array([cl, cr]) }
            end
          end

          describe '#limited?' do
            it { expect(node_cm.limited?).to be_falsey }
            it { expect(node_cb.limited?).to be_falsey }
            it { expect(node_cr.limited?).to be_falsey }
            it { expect(node_cc.limited?).to be_truthy }
          end

          describe '#different_atom_role?' do
            it { expect(node_cb.different_atom_role?).to be_truthy }
            it { expect(node_cm.different_atom_role?).to be_falsey }
          end
        end

      end
    end
  end
end
