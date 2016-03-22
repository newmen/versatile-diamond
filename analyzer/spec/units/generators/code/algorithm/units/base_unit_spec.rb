require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe BaseUnit, type: :algorithm do
          subject { described_class.new(dict, unit_nodes) }

          let(:return0) do
            -> { Expressions::Core::Return[Expressions::Core::Constant[0]] }
          end

          shared_context :predefined_two_mobs_context do
            include_context :two_mobs_context
            before { dict.make_specie_s(unit_nodes.map(&:uniq_specie)) }
            let(:unit_nodes) do # override
              [
                cbs_relation.first.first,
                cbs_relation.last.first.first.first
              ]
            end
          end

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

            shared_examples_for :check_atoms_roles_cond do
              before { dict.make_atom_s(atoms) }
              let(:expr) { subject.check_atoms_roles(atoms, &return0) }
              it { expect(expr.code).to eq(code) }
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

          describe '#iterate_specie_symmetries' do
            include_context :rab_context
            before { dict.make_specie_s(node_specie) }
            let(:code) do
              <<-CODE
bridge1->eachSymmetry([](ParentSpec *bridge2) {
    return 0;
})
              CODE
            end
            let(:expr) { subject.iterate_specie_symmetries(&return0) }
            it { expect(expr.code).to eq(code.rstrip) }
          end

          describe '#iterate_for_loop_symmetries' do
            include_context :predefined_two_mobs_context
            let(:expr) { subject.iterate_for_loop_symmetries(&return0) }

            describe 'no defined atoms' do
              let(:code) do
                <<-CODE
Atom *atoms1[2] = { species1[0]->atom(1), species1[1]->atom(1) };
for (uint a = 0; a < 2; ++a)
{
    return 0;
}
                CODE
              end
              it { expect(expr.code).to eq(code) }
            end

            describe 'just one atom is defined' do
              before { dict.make_atom_s(unit_nodes.first.atom) }
              let(:code) do
                <<-CODE
Atom *atom2 = species1[1]->atom(1);
Atom *atoms1[2] = { atom1, atom2 };
for (uint a = 0; a < 2; ++a)
{
    return 0;
}
                CODE
              end
              it { expect(expr.code).to eq(code) }
            end

            describe 'both atoms are separate defined' do
              before do
                dict.make_atom_s(unit_nodes.last.atom)
                dict.make_atom_s(unit_nodes.first.atom)
              end
              let(:code) do
                <<-CODE
Atom *atoms1[2] = { atom2, atom1 };
for (uint a = 0; a < 2; ++a)
{
    return 0;
}
                CODE
              end
              it { expect(expr.code).to eq(code) }
            end

            describe 'both atoms are defined as array' do
              before { dict.make_atom_s(unit_nodes.map(&:atom)) }
              let(:code) do
                <<-CODE
for (uint a = 0; a < 2; ++a)
{
    return 0;
}
                CODE
              end
              it { expect(expr.code).to eq(code) }
            end
          end

          describe '#iterate_species_by_role' do
            include_context :two_mobs_context
            before { dict.make_atom_s(cm) }

            let(:role_cm) { node_specie.source_role(cm) }
            let(:unit_nodes) { [entry_nodes.first.split.first] } # override
            let(:code) do
              <<-CODE
amorph1->eachSpecByRole<MethylOnBridge>(#{role_cm}, [](MethylOnBridge *methylOnBridge1) {
    return 0;
})
              CODE
            end
            let(:expr) { subject.iterate_species_by_role(&return0) }
            it { expect(expr.code).to eq(code.rstrip) }
          end

          describe '#define_undefined_atoms' do
            include_context :predefined_two_mobs_context
            let(:expr) { subject.define_undefined_atoms(&return0) }

            describe 'one atom is defined' do
              before { dict.make_atom_s(ctr) }
              let(:code) do
                <<-CODE
Atom *atom2 = species1[0]->atom(1);
return 0;
                CODE
              end
              it { expect(expr.code).to eq(code) }
            end

            describe 'both atoms are undefined' do
              let(:code) do
                <<-CODE
Atom *atoms1[2] = { species1[0]->atom(1), species1[1]->atom(1) };
return 0;
                CODE
              end
              it { expect(expr.code).to eq(code) }
            end
          end
        end

      end
    end
  end
end
