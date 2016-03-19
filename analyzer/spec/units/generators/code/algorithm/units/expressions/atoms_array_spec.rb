require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe AtomsArray, type: :algorithm do
          let(:dict) { VarsDictionary.new }
          let(:var) { dict.make_atom_s(atoms, name: 'atoms') }

          describe '#define_arg' do
            include_context :unique_parent_context
            let(:var) { dict.make_atom_s([cb, cm], name: 'as') }
            it { expect(var.define_arg.code).to eq('Atom **as1') }
          end

          shared_context :none_specie_calls do
            include_context :none_specie_context
            let(:species) { [subject] }
            let(:atoms) { [cr, cl] }
            let(:roles) { [4, 4] }
          end

          shared_context :uniq_parent_calls do
            include_context :specie_instance_context
            include_context :raw_none_specie_context
            include_context :raw_unique_parent_context

            let(:base_specs) { [dept_bridge_base, dept_none_specie] }

            let(:dept_none_specie) { dept_methyl_on_bridge_base }
            let(:dept_uniq_specie) { dept_methyl_on_bridge_base }

            let(:species) { [uniq_parent_inst, none_specie_inst] }
            let(:atoms) { [cb, cm] }
            let(:roles) { [8, 0] }
          end

          shared_context :uniq_reactant_calls do
            include_context :unique_reactant_context
            let(:species) { [subject] }
            let(:atoms) { [cb, cm] }
            let(:roles) { [8, 0] }
          end

          describe '#check_roles_in' do
            shared_examples_for :check_roles_code do
              let(:body) { Core::Return[Core::Constant[5]] }
              let(:code) do
                <<-CODE
if (atoms1[0]->is(#{roles[0]}) && atoms1[1]->is(#{roles[1]}))
{
    return 5;
}
                CODE
              end

              it { expect(var.check_roles_in(species, body).code).to eq(code) }
            end

            describe 'none specie' do
              include_context :none_specie_calls
              it_behaves_like :check_roles_code
            end

            describe 'unique parent' do
              include_context :uniq_parent_calls
              it_behaves_like :check_roles_code
            end

            describe 'unique reactant' do
              include_context :uniq_reactant_calls
              it_behaves_like :check_roles_code
            end
          end

          describe '#check_context' do
            shared_examples_for :check_context_code do
              let(:body) { Core::Return[Core::Constant[-5]] }
              let(:code) do
                <<-CODE
if (!atoms1[0]->hasRole(#{enum_name}, #{roles[0]}) || !atoms1[1]->hasRole(#{enum_name}, #{roles[1]}))
{
    return -5;
}
                CODE
              end

              it { expect(var.check_context(species, body).code).to eq(code) }
            end

            describe 'none specie' do
              include_context :none_specie_calls
              it_behaves_like :check_context_code
              let(:enum_name) { 'BRIDGE' }
            end

            describe 'unique parent' do
              include_context :uniq_parent_calls
              it_behaves_like :check_context_code
              let(:enum_name) { 'METHYL_ON_BRIDGE' }
            end

            describe 'unique reactant' do
              include_context :uniq_reactant_calls
              it_behaves_like :check_context_code
              let(:enum_name) { 'METHYL_ON_BRIDGE' }
            end
          end
        end

      end
    end
  end
end
