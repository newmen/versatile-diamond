require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe LateralContextProvider, type: :algorithm do
          include_context :look_around_context
          include_context :end_dimer_formation_lateral_context

          subject { described_class.new(dict, backbone.big_graph, ordered_graph) }

          describe '#key_nodes' do
            it { expect(subject.key_nodes).to match_array(entry_nodes) }
          end

          describe '#side_nodes' do
            it { expect(subject.side_nodes).to match_array(side_nodes) }
          end
        end

      end
    end
  end
end
