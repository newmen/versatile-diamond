require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentLateralReaction do
      subject do
        DependentLateralReaction.new(
          dimer_formation.lateral_duplicate('lateral', [on_middle]))
      end

      describe '#theres' do
        it { expect(subject.theres.map(&:class)).to eq([DependentThere]) }
      end
    end

  end
end
