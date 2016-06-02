require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe TargetSourcesUnit, type: :algorithm do
          subject { factory.sources_unit }
          let(:factory) { Algorithm::ReactionDoItUnitsFactory.new(changes) }
          let(:changes) { Algorithm::Changes.new(generator, typical_reaction) }

          describe '#define' do
            describe 'adsorption' do
              include_context :methyl_adsorbtion_context
              let(:m_node) { changes.main.find(&:gas?).product }
              let(:m_role) { m_node.uniq_specie.actual_role(m_node.atom) }
              let(:ct_node) { changes.main.reject(&:gas?).first }
              let(:ct_role) { ct_node.uniq_specie.actual_role(ct_node.atom) }
              let(:code) do
                <<-CODE
SpecificSpec *bridgeCTs1 = target();
assert(bridgeCTs1->type() == BRIDGE_CTs);
AtomBuilder builder;
Atom *atoms1[2] = { bridgeCTs1->atom(0), builder.buildC(#{m_role}, 1) };
assert(atoms1[0]->is(#{ct_role}));
                CODE
              end
              it { expect(subject.define.code).to eq(code.rstrip) }
            end

            describe 'only surface' do
              include_context :dimer_formation_context
              let(:code) do
                <<-CODE
SpecificSpec *species1[2] = { target(0), target(1) };
assert(species1[0]->type() == BRIDGE_CTs);
assert(species1[1]->type() == BRIDGE_CTsi);
Atom *atoms1[2] = { species1[1]->atom(0), species1[0]->atom(0) };
assert(atoms1[0]->is(3));
assert(atoms1[1]->is(2));
                CODE
              end
              it { expect(subject.define.code).to eq(code.rstrip) }
            end
          end
        end

      end
    end
  end
end
