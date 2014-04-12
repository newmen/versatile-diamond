require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentTermination do
      def wrap(spec)
        described_class.new(spec)
      end

      describe '#parents' do
        it { expect(wrap(active_bond).parents).to be_empty }
      end

      it_behaves_like :multi_parents do
        let(:parent) { DependentSpecificSpec.new(activated_bridge) }
        let(:child) { wrap(active_bond) }
      end
    end

  end
end
