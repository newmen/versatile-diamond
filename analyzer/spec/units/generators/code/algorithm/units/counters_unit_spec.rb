require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe CountersUnit, type: :algorithm do
          subject { described_class.new(dict, classifier) }
          let(:dict) { Expressions::RelationsDictionary.new }
          let(:classifier) { generator.classifier }
          let(:generator) do
            stub_generator(base_specs: base_specs, specific_specs: specific_specs)
          end

          let(:base_specs) do
            [
              dept_bridge_base,
              dept_dimer_base,
              dept_three_bridges_base,
              dept_methyl_on_bridge_base,
              dept_methyl_on_dimer_base,
              dept_methyl_on_dimer_base,
              dept_vinyl_on_bridge_base,
              dept_high_bridge_base,
            ]
          end
          let(:specific_specs) do
            [
              dept_activated_bridge,
              dept_activated_dimer,
            ]
          end

          describe '#define_counters' do
            it { expect(subject.define_counters.shifted_code).to eq(code) }
            let(:code) do
              <<-CODE
    ushort actives = atom->actives();
    ushort nFree = atom->amorphNeighboursNum();
    ushort nDouble = atom->doubleNeighboursNum();
    ushort nCrystal = atom->crystalNeighboursNum();
    ushort nFront_110;
    ushort nCross_110;
    ushort nFront_100;
    if (atom->lattice() && 0 < nCrystal)
    {
        nFront_110 = front_110(atom).num();
        nCross_110 = cross_110(atom).num();
        nFront_100 = front_100(atom).num();
    }
    else
    {
        nFront_110 = 0;
        nCross_110 = 0;
        nFront_100 = 0;
    }
    assert(nFront_110 + nCross_110 + nFront_100 <= nCrystal);
    assert(actives + nFree + nCrystal <= atom->valence());
    assert(actives + nDouble * 2 + nCrystal <= atom->valence());
              CODE
            end
          end
        end

      end
    end
  end
end
