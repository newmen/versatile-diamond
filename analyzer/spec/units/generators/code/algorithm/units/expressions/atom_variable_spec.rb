require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe AtomVariable, type: :algorithm do
          let(:namer) { Algorithm::Units::NameRemember.new }

          describe '#define_arg' do
            include_context :unique_parent_context
            let(:var) { described_class[namer, cb] }
            it { expect(var.define_arg.code).to eq('Atom *atom1') }
          end

          describe '#check_roles_in' do
            shared_examples_for :check_roles_code do
              let(:var) { described_class[namer, atom] }
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
        end

      end
    end
  end
end
