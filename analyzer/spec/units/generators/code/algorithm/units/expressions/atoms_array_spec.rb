require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe AtomsArray, type: :algorithm do
          let(:dict) { VarsDictionary.new }

          describe '#define_arg' do
            include_context :unique_parent_context
            let(:var) { dict.make_atom_s([cb, cm], name: 'as') }
            it { expect(var.define_arg.code).to eq('Atom **as1') }
          end

          describe '#check_roles_in' do
            shared_examples_for :check_roles_code do
              let(:var) { dict.make_atom_s(atoms, name: 'atoms') }
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
              include_context :none_specie_context
              it_behaves_like :check_roles_code do
                let(:species) { [subject] }
                let(:atoms) { [cr, cl] }
                let(:roles) { [4, 4] }
              end
            end

            describe 'unique parent' do
              include_context :specie_instance_context
              include_context :raw_none_specie_context
              include_context :raw_unique_parent_context

              let(:base_specs) { [dept_uniq_parent, dept_none_specie] }

              let(:dept_none_specie) { dept_methyl_on_bridge_base }
              let(:dept_uniq_specie) { dept_methyl_on_bridge_base }
              let(:dept_uniq_parent) { dept_bridge_base }

              it_behaves_like :check_roles_code do
                let(:species) { [uniq_parent_inst, none_specie_inst] }
                let(:atoms) { [cb, cm] }
                let(:roles) { [8, 0] }
              end
            end

            describe 'unique reactant' do
              include_context :unique_reactant_context
              it_behaves_like :check_roles_code do
                let(:species) { [subject] }
                let(:atoms) { [cb, cm] }
                let(:roles) { [8, 0] }
              end
            end
          end
        end

      end
    end
  end
end
