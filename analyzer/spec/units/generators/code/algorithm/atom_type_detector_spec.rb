require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe AtomTypeDetector, type: :algorithm do
          include_context :classified_props
          include_context :with_ubiquitous

          subject { described_class.new(classifier) }
          let(:classifier) { generator.classifier }
          let(:generator) do
            stub_generator(
              ubiquitous_reactions: ubiquitous_reactions,
              typical_reactions: [dept_hydrogen_abs_from_gap])
          end

          describe '#build' do
            it { expect(subject.build).to eq(code) }
            let(:code) do
              <<-CODE
    ushort actives = atom->actives();
    ushort nFront_110;
    ushort nCross_110;
    if (atom->lattice() && 0 < nCrystal)
    {
        nFront_110 = front_110(atom).num();
        nCross_110 = cross_110(atom).num();
    }
    else
    {
        nFront_110 = 0;
        nCross_110 = 0;
    }
    assert(actives + nFront_110 + nCross_110 <= atom->valence());
    if (actives == 0 && nCross_110 == 2 && nFront_110 == 2)
    {
        return #{tb_c};
    }
    else if (actives == 0 && nCross_110 == 2 && nFront_110 == 1)
    {
        return #{br_h};
    }
    else if (actives == 1 && nCross_110 == 2 && nFront_110 == 1)
    {
        return #{br_s};
    }
    else if (actives == 0 && nCross_110 == 2 && nFront_110 == 0)
    {
        return #{ct_hh};
    }
    else if (actives == 1 && nCross_110 == 2 && nFront_110 == 0)
    {
        return #{ct_sh};
    }
    else if (actives == 2 && nCross_110 == 2 && nFront_110 == 0)
    {
        return #{ct_ss};
    }
    else
    {
        assert(false);
        return NO_VALUE;
    }
              CODE
            end
          end
        end

      end
    end
  end
end
