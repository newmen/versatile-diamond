require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe BaseUnit, type: :algorithm do
          subject { described_class.new(dict, unit_nodes) }

          describe '#nodes' do
            include_context :two_mobs_context
            it { expect(subject.nodes).to eq(unit_nodes) }
          end

          describe '#species' do
            include_context :two_mobs_context
            it { expect(subject.species).to eq(uniq_parents) }
          end

          describe '#atoms' do
            include_context :two_mobs_context
            it { expect(subject.atoms).to eq([cm]) }
          end

          describe '#nodes_with' do
            include_context :two_mobs_context
            it { expect(subject.nodes_with([cm])).to eq(unit_nodes) }
            it { expect(subject.nodes_with([ctr])).to be_empty } # fake
          end

          describe '#check_atoms_roles' do
            [:cm, :ctr].each do |keyname|
              let("role_#{keyname}") { node_specie.actual_role(send(keyname)) }
            end
            let(:prc) do
              -> { Expressions::Core::Return[Expressions::Core::Constant[0]] }
            end

            shared_examples_for :check_atoms_roles_cond do
              before { dict.make_atom_s(atoms) }
              it { expect(subject.check_atoms_roles(atoms, &prc).code).to eq(code) }
            end

            describe 'specie with additional atom' do
              include_context :mob_context

              it_behaves_like :check_atoms_roles_cond do
                let(:atoms) { [cm] }
                let(:code) do
                  <<-CODE
if (amorph1->is(#{role_cm}))
{
    return 0;
}
                  CODE
                end
              end
            end

            describe 'two similar species' do
              include_context :two_mobs_context

              it_behaves_like :check_atoms_roles_cond do
                let(:atoms) { [cm] }
                let(:code) do
                  <<-CODE
if (amorph1->is(#{role_cm}))
{
    return 0;
}
                  CODE
                end
              end

              it_behaves_like :check_atoms_roles_cond do
                let(:atoms) { [ctl, ctr] }
                let(:code) do
                  <<-CODE
if (atoms1[0]->is(#{role_ctr}) && atoms1[1]->is(#{role_ctr}))
{
    return 0;
}
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
