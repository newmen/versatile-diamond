require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe AtomVariable, type: :algorithm do
          let(:var) { described_class[atom, AtomType[].ptr, 'atom'] }

          describe '#define_arg' do
            include_context :unique_parent_context
            let(:atom) { cb }
            it { expect(var.define_arg.code).to eq('Atom *atom') }
          end

          describe '#check_roles_in' do
            shared_examples_for :check_roles_code do
              let(:body) { Core::Return[var] }
              let(:code) do
                <<-CODE
if (atom->is(#{role}))
{
    return atom;
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
if (!atom->hasRole(#{enum_name}, #{role}))
{
    return yo(atom);
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
        end

      end
    end
  end
end
