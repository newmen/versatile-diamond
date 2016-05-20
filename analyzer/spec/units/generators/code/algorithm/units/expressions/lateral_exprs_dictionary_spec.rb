require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe LateralExprsDictionary, type: :algorithm do
          include_context :specie_instance_context
          include_context :raw_unique_reactant_context

          let(:base_specs) { [dept_bridge_base, dept_unique_reactant] }
          let(:dept_unique_reactant) { dept_methyl_on_bridge_base }

          let(:reactant1) do
            spec = Concepts::VeiledSpec.new(dept_unique_reactant.spec)
            Algorithm::Instances::UniqueReactant.new(generator, spec)
          end

          let(:reactant2) do
            spec = Concepts::VeiledSpec.new(dept_unique_reactant.spec)
            Algorithm::Instances::UniqueReactant.new(generator, spec)
          end

          let(:species_arr) { [reactant1, reactant2] }

          describe '#checkpoint! && #rollback!' do
            let(:proxy1) { Algorithm::Instances::OtherSideSpecie.new(reactant1) }
            let(:proxy2) { Algorithm::Instances::OtherSideSpecie.new(reactant1) }
            let(:proxy3) { Algorithm::Instances::OtherSideSpecie.new(reactant2) }
            let(:proxies12) { [proxy1, proxy2] }
            it 'expect sidepiece species' do
              subject.make_specie_s(reactant1)
              subject.make_specie_s(proxy1)
              subject.checkpoint!
              subject.make_specie_s(reactant2)
              subject.make_specie_s(proxy2)
              subject.make_specie_s(proxy3)
              expect(subject.same_vars(proxy1).map(&:instance)).to eq([proxy2])
              expect(subject.same_vars(proxy2).map(&:instance)).to eq([proxy1])
              expect(subject.same_vars(proxy3)).to be_empty
              expect(subject.different_vars(proxy1).map(&:instance)).to eq([proxy3])
              expect(subject.different_vars(proxy2).map(&:instance)).to eq([proxy3])
              expect(subject.different_vars(proxy3).map(&:instance)).to eq(proxies12)
              subject.rollback!
              expect(subject.same_vars(proxy1)).to be_empty
              expect(subject.same_vars(proxy3)).to be_empty
              expect(subject.different_vars(proxy1)).to be_empty
            end
          end

          describe '#var_of' do
            describe 'single target' do
              before { subject.make_target_s(reactant1) }
              it { expect(subject.var_of(reactant1).code).to eq('target()') }
            end

            describe 'many targets' do
              before { subject.make_target_s(species_arr) }
              it { expect(subject.var_of(species_arr)).to be_nil }
              it { expect(subject.var_of(reactant1).code).to eq('target(0)') }
              it { expect(subject.var_of(reactant2).code).to eq('target(1)') }
            end
          end
        end

      end
    end
  end
end
