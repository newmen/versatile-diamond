require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe HanserRecursiveAlgorithm do
      let(:free_bond) { Concepts::Bond[face: nil, dir: nil] }
      let(:bond_110) { Concepts::Bond[face: 110, dir: :front] }
      let(:position_100) { Concepts::Position[face: 100, dir: :front] }

      let(:lattice) { Concepts::Lattice.new(:d, 'Diamond') }
      let(:c) { Concepts::Atom.new('C', 4) }
      3.times do |i|
        let(:"c#{i}") do
          cd = c.dup
          cd.lattice = lattice; cd
        end
      end

      let(:bridge) do
        s = Concepts::Spec.new(:bridge, ct: c0, cr: c1, cl: c2)
        s.link(c0, c1, bond_110)
        s.link(c0, c2, bond_110)
        s.link(c1, c2, position_100)
        s.links
      end

      let(:methyl_on_bridge) do
        s = Concepts::Spec.new(:methyl_on_bridge,
          cm: c, cb: c0, cr: c1, cl: c2)

        s.link(c, c0, free_bond)
        s.link(c0, c1, bond_110)
        s.link(c0, c2, bond_110)
        s.link(c1, c2, position_100)
        s.links
      end

      let(:assoc) do
        AssocGraph.new(Graph.new(bridge), Graph.new(methyl_on_bridge))
      end

      describe "#self.contain?" do
        it { described_class.contain?(methyl_on_bridge, bridge).
          should be_true }

        it { described_class.contain?(bridge, methyl_on_bridge).
          should be_false }
      end

      describe "#self.first_interset" do
        subject { described_class.first_interset(assoc) }
        it { subject.size.should == 3 }
        it { subject.should include([c0, c0], [c1, c1], [c2, c2]) }
      end

      describe "#intersets" do
        subject { described_class.new(assoc).intersets }
        it { subject.size.should == 2 }
        it { subject.first.should include([c0, c0], [c1, c1], [c2, c2]) }
        it { subject.last.should include([c0, c0], [c1, c2], [c2, c1]) }
      end
    end

  end
end
