require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe LateralReaction do
      let(:reaction) { dimer_formation.lateral_duplicate('tail', [on_end]) }

      describe "#reverse" do
        subject { reaction.reverse }
        it { should be_a(described_class) }

        # TODO: check reversed theres
      end
    end

  end
end
