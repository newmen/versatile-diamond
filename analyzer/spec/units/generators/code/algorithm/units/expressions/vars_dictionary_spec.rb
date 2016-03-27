require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe VarsDictionary, type: :algorithm do
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

          let(:atoms_arr) { [cr, cl] }
          let(:species_arr) { [reactant2, reactant1] }

          subject { described_class.new }

          describe '#checkpoint! && #rollback!' do
            it 'expect names' do
              subject.make_atom_s(cb, name: 'cb')
              subject.make_atom_s(atoms_arr, name: 'arr')
              subject.checkpoint! # 1
              subject.make_atom_s(cb, name: 'other_cb')
              subject.make_specie_s(uniq_reactant_inst, name: 'spec')
              subject.rollback! # <- 1
              subject.make_specie_s(species_arr, name: 'arr')
              expect(subject.var_of(uniq_reactant_inst)).to be_nil
              expect(subject.var_of(species_arr).code).to eq('arrs2')
              expect(subject.var_of(atoms_arr).code).to eq('arrs1')
              expect(subject.var_of(cb).code).to eq('cb1')
              subject.checkpoint! # 2
              subject.make_specie_s(species_arr, name: 'lalas')
              expect(subject.var_of(species_arr).code).to eq('lalas1')
              subject.rollback! # <- 2
              expect(subject.var_of(species_arr).code).to eq('arrs2')
              subject.rollback! # <- 2
              expect(subject.var_of(species_arr).code).to eq('arrs2')
              subject.rollback!(forget: true) # <- 2
              expect(subject.var_of(species_arr).code).to eq('arrs2')
              subject.rollback!(forget: true) # <- 1
              expect(subject.var_of(species_arr)).to be_nil
              expect(subject.var_of(atoms_arr).code).to eq('arrs1')
              expect(subject.var_of(cb).code).to eq('cb1')
              subject.rollback!(forget: true) # <- 0
              expect(subject.var_of(species_arr)).to be_nil
              expect(subject.var_of(atoms_arr)).to be_nil
              subject.rollback! # <- 0
              subject.rollback!(forget: true) # no any error
            end
          end

          describe '#var_of' do
            describe 'single variable' do
              before { subject.make_atom_s(cb, name: 'cb') }
              it { expect(subject.var_of(cb).code).to eq('cb1') }
            end

            describe 'many variables' do
              before { subject.make_atom_s(atoms_arr, name: 'atom') }
              it { expect(subject.var_of(atoms_arr).code).to eq('atoms1') }
              it { expect(subject.var_of(atoms_arr.rotate(1)).code).to eq('atoms1') }
              it { expect(subject.var_of(cl).code).to eq('atoms1[1]') }
            end

            describe 'undefined variable' do
              it { expect(subject.var_of(cm)).to be_nil }
            end
          end

          describe '#prev_var_of' do
            describe 'undefined variable' do
              it { expect(subject.prev_var_of(cm)).to be_nil }
            end

            describe 'single stored variable' do
              before { subject.make_atom_s(cb, name: 'cb') }
              it { expect(subject.prev_var_of(cb)).to be_nil }
            end

            describe 'many stored variable' do
              before do
                subject.make_atom_s(cb, name: 'first_cb')
                subject.make_atom_s(cb, name: 'second_cb')
                subject.make_atom_s(cb, name: 'last_cb')
              end
              it { expect(subject.prev_var_of(cb).code).to eq('second_cb1') }
            end
          end

          describe '#defined_vars' do
            it { expect(subject.defined_vars).to be_empty }

            describe 'not empty' do
              let(:cb_var) { subject.make_atom_s(cb, name: 'x') }
              before { cb_var }
              it { expect(subject.defined_vars).to eq([cb_var]) }

              describe 'many' do
                let(:cm_var) { subject.make_atom_s(cm, name: 'y') }
                before { cm_var }
                it { expect(subject.defined_vars).to match_array([cb_var, cm_var]) }
              end

              describe 'repeat' do
                let(:other_var) { subject.make_atom_s(cb, name: 'z') }
                before { other_var }
                it { expect(subject.defined_vars).to match_array([cb_var, other_var]) }
              end
            end
          end
        end

      end
    end
  end
end
