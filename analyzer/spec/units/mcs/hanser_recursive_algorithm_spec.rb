require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe HanserRecursiveAlgorithm do
      let(:bridge_links) { bridge_base.links }
      let(:methyl_on_bridge_links) { methyl_on_bridge_base.links }
      let(:assoc) do
        AssocGraph.new(
          Graph.new(bridge_links), Graph.new(methyl_on_bridge_links))
      end

      describe "#self.contain?" do
        it { described_class.contain?(methyl_on_bridge_links, bridge_links).
          should be_true }
        it { described_class.contain?(bridge_links, methyl_on_bridge_links).
          should be_false }

        let(:methane_links) { methane_base.links }

        it { described_class.contain?(bridge_links, methane_links).
          should be_false }
        it { described_class.contain?(methane_links, bridge_links).
          should be_false }
        it { described_class.contain?(methyl_on_bridge_links, methane_links).
          should be_true }
        it { described_class.contain?(methane_links, methyl_on_bridge_links).
          should be_false }

        let(:methyl_on_dimer_links) { methyl_on_dimer_base.links }

        it { described_class.contain?(
          methyl_on_dimer_links, bridge_links).should be_true }
        it { described_class.contain?(
          bridge_links, methyl_on_dimer_links).should be_false }
        it { described_class.contain?(
          methyl_on_dimer_links, methyl_on_bridge_links).should be_true }
        it { described_class.contain?(
          methyl_on_bridge_links, methyl_on_dimer_links).should be_false }
        it { described_class.contain?(
          methyl_on_dimer_links, methane_links).should be_true }
        it { described_class.contain?(
          methane_links, methyl_on_dimer_links).should be_false }

        let(:high_bridge_links) { high_bridge_base.links }

        it { described_class.contain?(
          high_bridge_links, methyl_on_bridge_links).should be_true }

        describe "separated_multi_bond: true" do
          it { described_class.contain?(
            high_bridge_links, methyl_on_bridge_links ,
            separated_multi_bond: true).should be_false }
        end
      end

      describe "#self.first_interset" do
        subject { described_class.first_interset(assoc) }
        it { subject.size.should == 3 }
        it { subject.should include(
            [bridge_base.atom(:ct), methyl_on_bridge_base.atom(:cb)],
            [bridge_base.atom(:cr), methyl_on_bridge_base.atom(:cr)],
            [bridge_base.atom(:cl), methyl_on_bridge_base.atom(:cl)]
          ) }
      end

      describe "#intersets" do
        subject { described_class.new(assoc).intersets }
        it { subject.size.should == 2 }
        it { subject.first.should include(
            [bridge_base.atom(:ct), methyl_on_bridge_base.atom(:cb)],
            [bridge_base.atom(:cr), methyl_on_bridge_base.atom(:cr)],
            [bridge_base.atom(:cl), methyl_on_bridge_base.atom(:cl)]
          ) }
        it { subject.last.should include(
            [bridge_base.atom(:ct), methyl_on_bridge_base.atom(:cb)],
            [bridge_base.atom(:cr), methyl_on_bridge_base.atom(:cl)],
            [bridge_base.atom(:cl), methyl_on_bridge_base.atom(:cr)]
          ) }
      end
    end

  end
end
