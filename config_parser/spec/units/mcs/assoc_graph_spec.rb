require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe AssocGraph do
      let(:spec1) do
        s = Concepts::SurfaceSpec.new(:spec1, c1: cd1, c2: cd2)
        s.link(cd1, cd2, bond_100_front); s
      end
      let(:graph1) { Graph.new(spec1.links) }

      let(:cf) { cd1.dup }
      let(:cs) { cd1.dup }
      let(:spec2) do
        s = Concepts::SurfaceSpec.new(:spec2, cf: cf, cs: cs)
        s.link(cf, cs, position_front); s
      end
      let(:graph2) { Graph.new(spec2.links) }

      describe "exact match" do
        let(:assoc) { AssocGraph.new(graph1, graph2) }
        # before(:each) { assoc.save('assoc') }

        it { assoc.vertices.size.should == 4 }
        it { assoc.fbn([cd1, cf]).size.should == 3 }
      end

      describe "approximate match" do
        let(:assoc) do
          AssocGraph.new(graph1, graph2) { |_, _| true }
        end
        # before(:each) { assoc.save('assoc') }

        it { assoc.vertices.size.should == 4 }
        it { assoc.ext([cd1, cf]).size.should == 1 }
        it { assoc.ext([cd2, cs]).size.should == 1 }
        it { assoc.fbn([cd1, cf]).size.should == 2 }
      end
    end

  end
end
