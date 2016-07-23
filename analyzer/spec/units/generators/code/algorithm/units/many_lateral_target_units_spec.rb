require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe ManyLateralTargetUnits, type: :algorithm do
          include_context :look_around_context
          include_context :end_dimer_formation_lateral_context

          def nodes_to_mono_units(nodes)
            nodes.map { |node| MonoLateralTargetUnit.new(dict, node) }
          end

          def nodes_to_many_units(nodes)
            described_class.new(dict, nodes_to_mono_units(nodes))
          end

          before { subject.define! }

          subject { nodes_to_many_units(entry_nodes) }

          describe '#define!' do
            it { expect(dict.var_of(first_ts).code).to eq('target(0)') }
            it { expect(dict.var_of(last_ts).code).to eq('target(1)') }
          end

          describe '#checkable?' do
            it { expect(subject.checkable?).to be_falsey }
          end
        end

      end
    end
  end
end
