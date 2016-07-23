require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe MonoLateralTargetUnit, type: :algorithm do
          include_context :look_around_context
          include_context :small_activated_bridges_lateral_context

          before { subject.define! }

          subject { described_class.new(dict, node) }
          let(:node) { entry_nodes.first }

          describe '#define!' do
            let(:var) { dict.var_of(target_species) }
            it { expect(var.code).to eq('target()') }
          end

          describe '#checkable?' do
            it { expect(subject.checkable?).to be_falsey }
          end
        end

      end
    end
  end
end
