require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe LookAroundCreationUnit, type: :algorithm do
          include_context :look_around_context
          include_context :action_unit_context

          before { action_unit.define_scope! }
          subject { described_class.new(dict, context) }
          let(:context) do
            LateralContextProvider.new(dict, backbone.big_graph, ordered_graph)
          end

          describe '#create' do
            before { dict.make_specie_s(sidepiece_species) }
            let(:ccdan) { 'chunks[index++] = new' }

            describe 'side dimer' do
              include_context :end_dimer_formation_lateral_context
              let(:code) do
                <<-CODE
#{ccdan} ForwardDimerFormationEndLateral(this, species1[0])
                CODE
              end
              it { expect(subject.create.code).to eq(code.rstrip) }
            end

            describe 'side bridge' do
              include_context :small_activated_bridges_lateral_context
              let(:code) do
                <<-CODE
#{ccdan} CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTs(this, bridgeCTs1)
                CODE
              end
              it { expect(subject.create.code).to eq(code.rstrip) }
            end
          end
        end

      end
    end
  end
end
