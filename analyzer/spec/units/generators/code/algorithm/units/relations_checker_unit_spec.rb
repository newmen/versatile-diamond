require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe RelationsCheckerUnit, type: :algorithm do
          include_context :classified_props

          subject { described_class.new(dict, classifier) }
          let(:counter_unit) { CountersUnit.new(dict, lattice, classifier) }

          let(:dict) { Expressions::RelationsDictionary.new }
          let(:lattice) { Code::Lattice.new(generator, diamond) }
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
              dept_activated_incoherent_dimer,
            ]
          end

          describe '#build_conditions' do
            before { counter_unit.define_counters }
            it { expect(subject.build_conditions.shifted_code).to eq(code) }
            let(:code) do
              <<-CODE
    if (actives == 0 && nCross_110 == 2 && nCrystal == 3 && nDouble == 0 && nFree == 1 && nFront_100 == 1 && nFront_110 == 0)
    {
        return #{md_d};
    }
    else if (actives == 0 && nCross_110 == 2 && nCrystal == 2 && nDouble == 1 && nFree == 2 && nFront_100 == 0 && nFront_110 == 0)
    {
        return #{hc_f};
    }
    else if (actives == 0 && nCross_110 == 2 && nCrystal == 4 && nDouble == 0 && nFree == 0 && nFront_100 == 0 && nFront_110 == 2)
    {
        return #{tb_c};
    }
    else if (actives == 1 && nCross_110 == 2 && nCrystal == 3 && nDouble == 0 && nFree == 0 && nFront_100 == 1 && nFront_110 == 0)
    {
        return #{cd_s};
    }
    else if (actives == 0 && nCross_110 == 2 && nCrystal == 3 && nDouble == 0 && nFree == 0 && nFront_100 == 1 && nFront_110 == 0)
    {
        return #{cd_i};
    }
    else if (actives == 0 && nCross_110 == 2 && nCrystal == 2 && nDouble == 0 && nFree == 1 && nFront_100 == 0 && nFront_110 == 0)
    {
        return #{cb_f};
    }
    else if (actives == 0 && nCross_110 == 2 && nCrystal == 3 && nDouble == 0 && nFree == 0 && nFront_100 == 0 && nFront_110 == 1)
    {
        return #{br_f};
    }
    else if (actives == 2 && nCross_110 == 2 && nCrystal == 2 && nDouble == 0 && nFree == 0 && nFront_100 == 0 && nFront_110 == 0)
    {
        return #{ct_ss};
    }
    else if (actives == 1 && nCross_110 == 2 && nCrystal == 2 && nDouble == 0 && nFree == 0 && nFront_100 == 0 && nFront_110 == 0)
    {
        return #{ct_s};
    }
    else if (actives == 0 && nCross_110 == 2 && nCrystal == 2 && nDouble == 0 && nFree == 0 && nFront_100 == 0 && nFront_110 == 0)
    {
        return #{ct_f};
    }
    else if (actives == 0 && nCross_110 == 0 && nCrystal == 1 && nDouble == 1 && nFree == 3 && nFront_100 == 0 && nFront_110 == 0)
    {
        return #{cv_f};
    }
    else if (actives == 0 && nCross_110 == 0 && nCrystal == 0 && nDouble == 1 && nFree == 2 && nFront_100 == 0 && nFront_110 == 0)
    {
        return #{cw_f};
    }
    else if (actives == 0 && nCross_110 == 0 && nCrystal == 2 && nDouble == 1 && nFree == 2 && nFront_100 == 0 && nFront_110 == 0)
    {
        return #{hm_f};
    }
    else if (actives == 0 && nCross_110 == 0 && nCrystal == 1 && nDouble == 0 && nFree == 1 && nFront_100 == 0 && nFront_110 == 0)
    {
        return #{cm_f};
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
