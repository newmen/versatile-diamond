require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe AtomReference do
      let(:c1) { Atom.new('C', 4) }
      let(:c2) { c1.dup }
      let(:bond) { Bond[face: nil, dir: nil] }
      let(:ethylene) do
        spec = Spec.new(:ethylene, c1: c1, c2: c2)
        spec.link(c1, c2, bond)
        spec.link(c1, c2, bond)
        spec
      end
      let(:atom_ref) { AtomReference.new(ethylene, :c1) }

      describe "#valence" do
        it { atom_ref.valence.should == 2 }
      end

      describe "#lattice" do
        it { atom_ref.lattice.should be_nil }

        it "ref to latticed atom" do
          lattice = Lattice.new(:d, cpp_class: 'Diamond')
          c1.lattice = lattice
          spec = Spec.new(:some, c: c1)
          ref = AtomReference.new(spec, :c)
          ref.lattice.should == lattice
        end
      end
    end

  end
end
