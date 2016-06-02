require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe ReactionCreationUnit, type: :algorithm do
          subject { described_class.new(dict, context, typical_reaction) }
          let(:context) do
            ReactionContextProvider.new(dict, backbone.big_graph, ordered_graph)
          end
          let(:bone_nodes) { context.bone_nodes }

          describe '#create' do
            let(:reactants) { bone_nodes.map(&:uniq_specie).uniq.sort }

            describe 'just one reactant' do
              include_context :methyl_adsorbtion_context
              before { dict.make_specie_s(node_specie) }
              let(:code) { 'create<ForwardMethylAdsorption>(bridgeCTs1)' }
              it { expect(subject.create.code).to eq(code) }
            end

            describe 'reactants not same arr' do
              include_context :dimer_formation_context
              before { reactants.map(&dict.public_method(:make_specie_s)) }
              let(:code) do
                <<-CODE
SpecificSpec *targets[2] = { bridgeCTs1, bridgeCTsi1 };
create<ForwardDimerFormation>(targets);
                CODE
              end
              it { expect(subject.create.code).to eq(code.rstrip) }
            end

            describe 'reactants already same arr' do
              include_context :dimer_formation_context
              before do
                instances_type = Expressions::ReactantSpecieType[]
                dict.make_specie_s(reactants, type: instances_type)
              end
              let(:code) { 'create<ForwardDimerFormation>(species1)' }
              it { expect(subject.create.code).to eq(code) }
            end
          end
        end

      end
    end
  end
end
