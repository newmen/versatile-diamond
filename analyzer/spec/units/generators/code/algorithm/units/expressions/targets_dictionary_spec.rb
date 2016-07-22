require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe TargetsDictionary, type: :algorithm do
          include_context :dimer_formation_context

          subject { described_class.new(typical_reaction) }

          let(:nodes) { entry_nodes }
          let(:species_arr) { nodes_species + nbr_species }
          let(:reactant1) { species_arr.first }
          let(:reactant2) { species_arr.last }

          describe '#checkpoint! && #rollback!' do
            it 'expect sidepiece species' do
              subject.make_this
              subject.checkpoint!
              subject.make_target_s(reactant1)
              expect(subject.var_of(:this).code).to eq('this')
              expect(subject.var_of(reactant1).code).to eq('target()')
              subject.rollback!
              expect(subject.var_of(:this)).not_to be_nil
              expect(subject.var_of(reactant1)).to be_nil
              subject.rollback!(forget: true)
              expect(subject.var_of(:this)).not_to be_nil
              subject.rollback!(forget: true)
              expect(subject.var_of(:this)).to be_nil
            end
          end

          describe '#make_this' do
            describe 'not defined' do
              it { expect(subject.var_of(:this)).to be_nil }
            end

            describe 'defined one time' do
              before { this }
              let(:this) { subject.make_this }
              it { expect(subject.var_of(:this)).to eq(this) }
              it { expect(subject.make_this).to equal(this) }
            end

            describe 'defined after rollback' do
              before do
                this # define and cache
                subject.rollback!
              end
              let(:this) { subject.make_this } # cached
              it { expect(subject.make_this).not_to equal(this) }
            end
          end

          describe '#make_target_s' do
            before { subject.make_target_s(reactant1) }
            it { expect(subject.var_of(reactant1).code).to eq('target()') }

            describe 'deny to make again' do
              it { expect { subject.make_target_s(reactant1) }.to raise_error }
              it { expect { subject.make_target_s(reactant2) }.to raise_error }
            end

            describe 'allow after rollback' do
              before { subject.rollback! }
              it { expect { subject.make_target_s(reactant1) }.not_to raise_error }
              it { expect { subject.make_target_s(reactant2) }.not_to raise_error }
            end
          end

          describe '#var_of' do
            describe 'single target' do
              before { subject.make_target_s(reactant1) }
              it { expect(subject.var_of(reactant1).code).to eq('target()') }
            end

            describe 'single item' do
              before { subject.make_target_s([reactant1]) }
              it { expect(subject.var_of(reactant1).code).to eq('target()') }
            end

            describe 'many targets' do
              before { subject.make_target_s(species_arr) }
              it { expect(subject.var_of(species_arr)).to be_nil }
              it { expect(subject.var_of(reactant1).code).to eq('target(0)') }
              it { expect(subject.var_of(reactant2).code).to eq('target(1)') }
            end
          end

          describe '#defined_vars' do
            before { var }
            let(:var) { subject.make_specie_s(reactant1) }

            describe 'without targets' do
              it { expect(subject.defined_vars).to eq([var]) }
            end

            describe 'with target' do
              before { subject.make_target_s(reactant2) }
              let(:vars) { [subject.make_this, var] }
              it { expect(subject.defined_vars).to match_array(vars) }
            end
          end
        end

      end
    end
  end
end
