require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe AssocGraph do
      let(:spec1) do
        s = Concepts::SurfaceSpec.new(:spec1, c1: cd1, c2: cd2)
        s.link(cd1, cd2, bond_100_front); s
      end
      let(:graph1) { Graph.new(spec1) }

      let(:cf) { cd1.dup }
      let(:cs) { cd1.dup }
      let(:spec2) do
        s = Concepts::SurfaceSpec.new(:spec2, cf: cf, cs: cs)
        s.link(cf, cs, position_100_front); s
      end
      let(:graph2) { Graph.new(spec2) }

      def collect_edges(vname)
        result = []
        assoc.public_send(:"each_#{vname}_edge") do |v, w|
          result << [v, w]
        end
        result
      end

      describe 'exact match' do
        let(:assoc) { described_class.new(graph1, graph2) }
        # before(:each) { assoc.save('assoc') }

        it { expect(assoc.vertices.size).to eq(4) }
        it { expect(collect_edges(:ext).size).to eq(0) }
        it { expect(collect_edges(:fbn).size).to eq(12) }
      end

      describe 'approximate match' do
        let(:assoc) do
          described_class.new(graph1, graph2) { |_, _| true }
        end
        # before(:each) { assoc.save('assoc') }

        it { expect(assoc.vertices.size).to eq(4) }
        it { expect(collect_edges(:ext).size).to eq(4) }
        it { expect(collect_edges(:fbn).size).to eq(8) }
      end
    end

  end
end
