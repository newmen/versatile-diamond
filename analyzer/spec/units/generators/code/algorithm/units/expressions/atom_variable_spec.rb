require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe AtomVariable, type: :algorithm do
          let(:dict) { VarsDictionary.new }
          let(:var) { dict.make_atom_s(atom, name: 'atom') }

          describe '#define_arg' do
            include_context :unique_parent_context
            let(:atom) { cb }
            it { expect(var.define_arg.code).to eq('Atom *atom1') }
          end

          describe '#check_roles_in' do
            shared_examples_for :check_roles_code do
              let(:body) { Core::Return[var] }
              let(:code) do
                <<-CODE
if (atom1->is(#{role}))
{
    return atom1;
}
                CODE
              end

              it { expect(var.check_roles_in([subject], body).code).to eq(code) }
            end

            describe 'none specie' do
              include_context :none_specie_context
              it_behaves_like :check_roles_code do
                let(:atom) { ct }
                let(:role) { 0 }
              end
            end

            describe 'unique parent' do
              include_context :unique_parent_context
              it_behaves_like :check_roles_code do
                let(:atom) { cb }
                let(:role) { 8 }
              end
            end

            describe 'unique reactant' do
              include_context :unique_reactant_context
              it_behaves_like :check_roles_code do
                let(:atom) { cb }
                let(:role) { 8 }
              end
            end
          end

          describe '#check_context' do
            shared_examples_for :check_roles_code do
              let(:body) { Core::Return[Core::FunctionCall['yo', var]] }
              let(:code) do
                <<-CODE
if (!atom1->hasRole(#{enum_name}, #{role}))
{
    return yo(atom1);
}
                CODE
              end

              it { expect(var.check_context([subject], body).code).to eq(code) }
            end

            describe 'none specie' do
              include_context :none_specie_context
              it_behaves_like :check_roles_code do
                let(:atom) { ct }
                let(:enum_name) { 'BRIDGE' }
                let(:role) { 0 }
              end
            end

            describe 'unique parent' do
              include_context :unique_parent_context
              it_behaves_like :check_roles_code do
                let(:atom) { cb }
                let(:enum_name) { 'METHYL_ON_BRIDGE' }
                let(:role) { 8 }
              end
            end

            describe 'unique reactant' do
              include_context :unique_reactant_context
              it_behaves_like :check_roles_code do
                let(:atom) { cb }
                let(:enum_name) { 'METHYL_ON_BRIDGE' }
                let(:role) { 8 }
              end
            end
          end

          describe '#each_specie_by_role' do
            shared_examples_for :check_roles_code do
              let(:specie_var) { dict.make_specie_s(subject) }
              let(:body) { Core::Return[specie_var] }
              let(:result) { var.each_specie_by_role([], specie_var, body) }
              it { expect(result.code).to eq(code.rstrip) }
            end

            describe 'none specie' do
              include_context :none_specie_context
              it_behaves_like :check_roles_code do
                let(:atom) { ct }
                let(:code) do
                  <<-CODE
atom1->eachSpecByRole<Bridge>(0, [](Bridge *bridge1) {
    return bridge1;
})
                  CODE
                end
              end
            end

            describe 'unique parent' do
              include_context :unique_parent_context
              it_behaves_like :check_roles_code do
                let(:atom) { cb }
                let(:code) do
                  <<-CODE
atom1->eachSpecByRole<Bridge>(2, [](Bridge *bridge1) {
    return bridge1;
})
                  CODE
                end
              end
            end

            describe 'unique reactant' do
              include_context :unique_reactant_context
              it_behaves_like :check_roles_code do
                let(:atom) { cb }
                let(:code) do
                  <<-CODE
atom1->eachSpecByRole<MethylOnBridge>(8, [](MethylOnBridge *methylOnBridge1) {
    return methylOnBridge1;
})
                  CODE
                end
              end
            end
          end
        end

      end
    end
  end
end
