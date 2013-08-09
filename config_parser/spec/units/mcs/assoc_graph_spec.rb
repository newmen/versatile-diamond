require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe AssocGraph do
      let(:c1) { Concepts::Atom.new('C', 4) }
      let(:c2) { c1.dup }
      let(:spec1) do
        s = Concepts::Spec.new(:spec1, c1: c1, c2: c2)
        s.link(c1, c2, Concepts::Bond[face: 100, dir: :front]); s
      end
      let(:graph1) { Graph.new(spec1.links) }

      # let(:lattice) { Concepts::Lattice.new(:d, 'Diamond') }
      let(:cf) { c1.dup }
      let(:cs) { c1.dup }
      # let(:cs) do
      #   c = c1.dup
      #   c.lattice = lattice; c
      # end
      let(:spec2) do
        s = Concepts::Spec.new(:spec2, cf: cf, cs: cs)
        s.link(cf, cs, Concepts::Position[face: 100, dir: :front]); s
      end
      let(:graph2) { Graph.new(spec2.links) }

      describe "exact match" do
        let(:assoc) { AssocGraph.new(graph1, graph2) }
        # before(:each) { assoc.save('assoc') }

        it { assoc.vertices.size.should == 4 }
        it { assoc.fbn([c1, cf]).size.should == 3 }
      end

      describe "approximate match" do
        let(:assoc) do
          AssocGraph.new(graph1, graph2) { |_, _| true }
        end
        # before(:each) { assoc.save('assoc') }

        it { assoc.vertices.size.should == 4 }
        it { assoc.ext([c1, cf]).size.should == 1 }
        it { assoc.ext([c2, cs]).size.should == 1 }
        it { assoc.fbn([c1, cf]).size.should == 2 }
      end
    end

  end
end
