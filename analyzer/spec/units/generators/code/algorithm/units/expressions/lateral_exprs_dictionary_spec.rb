require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe LateralExprsDictionary, type: :algorithm do
          include_context :look_around_context
          include_context :small_activated_bridges_lateral_context

          subject { described_class.new(action_nodes) }
          let(:species_arr) { action_nodes.map(&:uniq_specie) }
          let(:reactant1) { species_arr.first }
          let(:reactant2) { species_arr.last }

          describe '#checkpoint! && #rollback!' do
            let(:proxy1) { Algorithm::Instances::OtherSideSpecie.new(reactant1) }
            let(:proxy2) { Algorithm::Instances::OtherSideSpecie.new(reactant1) }
            let(:proxy3) { Algorithm::Instances::OtherSideSpecie.new(reactant2) }
            let(:side_atom) { side_nodes.first.atom }
            let(:side_atoms) { [side_atom, side_atom.dup] }
            let(:act_atoms) { action_nodes.map(&:atom) }
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

              subject.make_atom_s(act_atoms)
              expect(subject.var_of(act_atoms).code).to eq('atoms1')
              subject.rollback!
              expect(subject.var_of(act_atoms).instance).to eq(act_atoms)
              expect(subject.var_of(act_atoms.first).instance).to eq(act_atoms.first)
              expect(subject.var_of(act_atoms.last).instance).to eq(act_atoms.last)
              subject.make_atom_s(side_atoms)
              expect(subject.var_of(act_atoms).code).to eq('atoms1')
              expect(subject.var_of(side_atoms).code).to eq('atoms2')
              subject.rollback!
              expect(subject.var_of(act_atoms).code).to eq('atoms1')
              expect(subject.var_of(side_atoms)).to be_nil
              subject.rollback!(forget: true)
              expect(subject.var_of(act_atoms)).to be_nil
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
