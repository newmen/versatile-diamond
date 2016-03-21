require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        describe ReactantNode, type: :algorithm do
          let(:generator) do
            stub_generator(
              specific_specs: [dept_aib, dept_ab],
              typical_reactions: [reaction])
          end

          let(:factory) { Algorithm::ReactionNodesFactory.new(generator) }
          let(:reaction) { dept_dimer_formation }
          let(:targets) { reaction.changes.map(&:first) }
          let(:nodes) { targets.map(&factory.public_method(:get_node)).sort }

          let(:node_aib) { nodes.first }
          let(:node_ab) { nodes.last }
          let(:dept_aib) { dept_activated_incoherent_bridge }
          let(:dept_ab) { dept_activated_bridge }

          let(:source) { targets.map(&:first) }
          let(:concept_aib) { source.last }
          let(:concept_ab) { source.first }

          describe '#uniq_specie' do
            let(:specie_instance_class) { Algorithm::Instances::UniqueReactant }

            let(:code_aib) { generator.specie_class(concept_aib.name) }
            it { expect(node_aib.uniq_specie.original).to eq(code_aib) }
            it { expect(node_aib.uniq_specie).to be_a(specie_instance_class) }

            let(:code_ab) { generator.specie_class(concept_ab.name) }
            it { expect(node_ab.uniq_specie.original).to eq(code_ab) }
            it { expect(node_ab.uniq_specie).to be_a(specie_instance_class) }
          end

          describe '#spec' do
            it { expect(node_aib.spec).not_to eq(dept_aib) }
            it { expect(node_aib.spec.spec).to eq(concept_aib) }

            it { expect(node_ab.spec).not_to eq(dept_ab) }
            it { expect(node_ab.spec.spec).to eq(concept_ab) }
          end

          describe '#anchor?' do
            it { expect(node_aib.anchor?).to be_truthy }
            it { expect(node_ab.anchor?).to be_truthy }
          end

          describe '#used_many_times?' do
            it { expect(node_aib.used_many_times?).to be_falsey }
            it { expect(node_ab.used_many_times?).to be_falsey }
          end

          describe '#usages_num' do
            it { expect(node_aib.usages_num).to eq(1) }
            it { expect(node_ab.usages_num).to eq(1) }
          end

          describe '#lattice' do
            it { expect(node_aib.lattice).not_to be_nil }
            it { expect(node_aib.lattice).to eq(node_ab.lattice) }
          end

          describe '#relations_limits' do
            it { expect(node_aib.relations_limits).to be_a(Hash) }
            it { expect(node_ab.relations_limits).to be_a(Hash) }
            it { expect(node_ab.relations_limits).to eq(node_aib.relations_limits) }
          end

          describe '#<=>' do
            it { expect(node_aib <=> node_ab).to eq(-1) }
            it { expect(node_ab <=> node_aib).to eq(1) }
          end

          describe '#properties' do
            let(:atom_aib) { dept_aib.spec.atom(:ct) }
            let(:props_aib) { Organizers::AtomProperties.new(dept_aib, atom_aib) }
            it { expect(node_aib.properties).to eq(props_aib) }

            let(:atom_ab) { dept_ab.spec.atom(:ct) }
            let(:props_ab) { Organizers::AtomProperties.new(dept_ab, atom_ab) }
            it { expect(node_ab.properties).to eq(props_ab) }
          end

          describe '#sub_properties' do
            let(:atom_ab) { dept_ab.spec.atom(:ct) }
            let(:props_ab) { Organizers::AtomProperties.new(dept_ab, atom_ab) }
            it { expect(node_ab.sub_properties).to eq(props_ab) }
          end

          describe '#spec_atom' do
            let(:atom_aib) { concept_aib.atom(:ct) }
            it { expect(node_aib.spec_atom).to eq([concept_aib, atom_aib]) }

            let(:atom_ab) { concept_ab.atom(:ct) }
            it { expect(node_ab.spec_atom).to eq([concept_ab, atom_ab]) }
          end
        end

      end
    end
  end
end
