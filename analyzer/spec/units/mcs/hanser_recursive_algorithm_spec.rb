require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe HanserRecursiveAlgorithm do
      let(:bridge_graph) { Graph.new(bridge_base) }
      let(:methyl_on_bridge_graph) { Graph.new(methyl_on_bridge_base) }
      let(:assoc) { AssocGraph.new(bridge_graph, methyl_on_bridge_graph) }

      describe '#self.first_intersec' do
        subject { described_class.first_intersec(assoc) }

        it { expect(subject.size).to eq(3) }
        it { expect(subject).to include(
            [bridge_base.atom(:ct), methyl_on_bridge_base.atom(:cb)],
            [bridge_base.atom(:cr), methyl_on_bridge_base.atom(:cr)],
            [bridge_base.atom(:cl), methyl_on_bridge_base.atom(:cl)]
          ) }
      end

      describe '#intersec' do
        subject { described_class.new(assoc).intersec }

        it { expect(subject.size).to eq(2) }
        it { expect(subject.first).to include(
            [bridge_base.atom(:ct), methyl_on_bridge_base.atom(:cb)],
            [bridge_base.atom(:cr), methyl_on_bridge_base.atom(:cr)],
            [bridge_base.atom(:cl), methyl_on_bridge_base.atom(:cl)]
          ) }
        it { expect(subject.last).to include(
            [bridge_base.atom(:ct), methyl_on_bridge_base.atom(:cb)],
            [bridge_base.atom(:cr), methyl_on_bridge_base.atom(:cl)],
            [bridge_base.atom(:cl), methyl_on_bridge_base.atom(:cr)]
          ) }
      end
    end

  end
end
