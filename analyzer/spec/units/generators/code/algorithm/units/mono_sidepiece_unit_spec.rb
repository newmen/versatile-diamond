require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe MonoSidepieceUnit, type: :algorithm, use: :chunks do
          include_context :check_laterals_context
          include_context :small_activated_bridges_lateral_context

          before { subject.define! }

          subject { described_class.new(dict, node) }
          let(:node) { entry_nodes.first }
          let(:spec) { front_bridge }

          describe '#define!' do
            let(:var) { dict.var_of(target_species) }
            it { expect(var.code).to eq('sidepiece') }
          end

          describe '#checkable?' do
            it { expect(subject.checkable?).to be_falsey }
          end
        end

      end
    end
  end
end
