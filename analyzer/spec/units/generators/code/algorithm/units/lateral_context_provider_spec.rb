require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe LateralContextProvider, type: :algorithm do
          include_context :look_around_context

          subject { described_class.new(dict, backbone.big_graph, ordered_graph) }

          describe '#key_nodes' do
            include_context :end_dimer_formation_lateral_context
            it { expect(subject.key_nodes).to match_array(entry_nodes) }
          end

          describe '#side_nodes' do
            include_context :end_dimer_formation_lateral_context
            it { expect(subject.side_nodes).to match_array(side_nodes) }
          end

          describe '#symmetric_actions?' do
            let(:result) { subject.symmetric_actions?(action_nodes) }

            describe 'lateral dimer formation' do
              include_context :end_dimer_formation_lateral_context
              it { expect(result).to be_falsey }
            end

            describe 'many similar activated bridges' do
              include_context :small_activated_bridges_lateral_context
              it { expect(result).to be_truthy }
            end
          end
        end

      end
    end
  end
end
