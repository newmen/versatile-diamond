module VersatileDiamond
  module Concepts

    describe SpecificAtom do
      let(:atom) { Atom.new('N', 3) }
      let(:specific_atom) { SpecificAtom.new(atom) }

      describe "#actives" do
        it { specific_atom.actives.should == 0 }

        it "value changes when atom activated" do
          specific_atom.active!
          specific_atom.actives.should == 1
        end
      end
    end

  end
end
