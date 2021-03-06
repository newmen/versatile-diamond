require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe BasePureUnit, type: :algorithm do
          subject { described_class.new(dict, unit_nodes) }

          let(:return0) do
            -> { Expressions::Core::Return[Expressions::Core::Constant[0]] }
          end

          shared_context :predefined_two_mobs_context do
            include_context :alt_two_mobs_context
            before { dict.make_specie_s(uniq_parents) }
          end

          describe '#<=>' do
            include_context :two_mobs_context
            let(:cm) { unit_nodes.first }
            let(:ctr) { cbs_relation.first.first }
            let(:ctl) { cbs_relation.last.first.first.first }

            it { expect(cm <=> ctr).to eq(1) }
            it { expect(ctr <=> cm).to eq(-1) }
            it { expect(ctr <=> ctl).to eq(0) }
            it { expect(ctl <=> ctr).to eq(0) }
          end

          describe '#nodes' do
            include_context :two_mobs_context
            it { expect(subject.nodes).to eq(unit_nodes) }
          end

          describe '#species' do
            include_context :two_mobs_context
            it { expect(subject.species).to eq(uniq_parents) }
          end

          describe '#anchored_species' do
            let(:species) { subject.species }
            let(:num) { 1 }

            shared_examples_for :check_anchored_species do
              it { expect(subject.anchored_species).to eq(species) }
              it { expect(subject.anchored_species.size).to eq(num) }
            end

            it_behaves_like :check_anchored_species do
              include_context :bridge_context
            end

            it_behaves_like :check_anchored_species do
              include_context :rab_context
            end

            it_behaves_like :check_anchored_species do
              include_context :two_mobs_context
              let(:num) { 2 } # override
            end

            it_behaves_like :check_anchored_species do
              include_context :top_mob_context
            end

            it_behaves_like :check_anchored_species do
              include_context :alt_top_mob_context
              let(:species) { [subject.species.max] } # => [Bridge]
            end
          end

          describe '#atoms' do
            include_context :two_mobs_context
            it { expect(subject.atoms).to eq([cm]) }
          end

          describe '#symmetric_atoms' do
            include_context :rab_context
            it { expect(subject.symmetric_atoms).to match_array([cl, cr]) }
          end

          describe '#complete_inner_units' do
            describe 'mono unit' do
              include_context :rab_context
              subject { MonoPureUnit.new(dict, unit_nodes.first) }

              describe 'undefined' do
                it { expect(subject.complete_inner_units).to be_empty }
              end

              describe 'defined' do
                before { dict.make_atom_s(cr) }
                it { expect(subject.complete_inner_units).to eq([subject]) }
              end
            end

            describe 'many units' do
              subject { ManyPureUnits.new(dict, mono_units) }
              let(:mono_units) do
                unit_nodes.map { |node| MonoPureUnit.new(dict, node) }
              end

              describe 'undefined' do
                include_context :tree_bridges_context
                it { expect(subject.complete_inner_units).to be_empty }
              end

              describe 'defined both non complete' do
                include_context :tree_bridges_context
                before { dict.make_atom_s(cc) }
                it { expect(subject.complete_inner_units).to eq([subject]) }
              end

              describe 'defined just one complete' do
                include_context :alt_top_mob_context
                before { dict.make_atom_s(cr) }
                it { expect(subject.complete_inner_units).to eq(mono_units.sort) }
              end
            end
          end

          describe '#atom_with_specie_calls' do
            include_context :alt_two_mobs_context
            before { dict.make_atom_s(ctl) }
            let("role_ctl") { node_specie.actual_role(ctl) }
            let(:expr) { subject.atom_with_specie_calls(:role_in, [ctl], &:anchor?) }
            it { expect(expr.map(&:code)).to eq(["atom1->is(#{role_ctl})"]) }
          end

          describe '#check_atoms_roles' do
            [:cm, :cb, :ctr].each do |keyname|
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
                let(:atoms) { [cb] }
                let(:code) do
                  <<-CODE
if (atom1->is(#{role_cb}))
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

          describe '#check_amorph_bonds_if_have' do
            shared_examples_for :check_amorph_bonds_block do
              let(:empty_proc) { -> &block { block.call } }
              let(:expr) do
                subject.check_amorph_bonds_if_have(nbr, empty_proc, &return0)
              end
              it { expect(expr.code).to eq(code.rstrip) }
            end

            describe 'amprph bonds' do
              let(:amorph_nodes) { ordered_graph.first.last.first.first }

              it_behaves_like :check_amorph_bonds_block do
                include_context :mob_context
                before { dict.make_atom_s(cb) }
                let(:nbr) { described_class.new(dict, amorph_nodes) }
                let(:code) do
                  <<-CODE
atom1->eachAmorphNeighbour([](Atom *amorph1) {
    return 0;
})
                  CODE
                end
              end

              it_behaves_like :check_amorph_bonds_block do
                include_context :mob_context
                before { dict.make_atom_s(cm) }
                subject { described_class.new(dict, amorph_nodes) } # override
                let(:nbr) { described_class.new(dict, unit_nodes) }
                let(:code) do
                  <<-CODE
amorph1->eachCrystalNeighbour([](Atom *atom1) {
    return 0;
})
                  CODE
                end
              end
            end

            describe 'crystal bonds' do
              let(:nbr) { described_class.new(dict, other_side_nodes) }

              it_behaves_like :check_amorph_bonds_block do
                include_context :alt_intermed_context
                let(:other_side_nodes) do
                  ordered_graph.select { |k, _| k == unit_nodes }.last.first
                end
                let(:code) { 'return 0' }
              end

              describe 'from two atoms' do
                include_context :half_intermed_context
                let(:other_side_nodes) { ordered_graph.last.first }

                it_behaves_like :check_amorph_bonds_block do
                  before { dict.make_atom_s([cdl, cdr]) }
                  let(:code) { 'return 0' }
                end

                it_behaves_like :check_amorph_bonds_block do
                  before do
                    dict.make_atom_s([cdl, cdr])
                    dict.make_atom_s([cbl, cbr])
                  end
                  let(:code) { 'return 0' }
                end

                it_behaves_like :check_amorph_bonds_block do
                  include_context :half_intermed_context
                  before do
                    dict.make_atom_s(cdr)
                    dict.make_atom_s(cdl)
                  end
                  let(:code) do
                    <<-CODE
Atom *atoms1[2] = { atom2, atom1 };
return 0;
                    CODE
                  end
                end

                it_behaves_like :check_amorph_bonds_block do
                  include_context :half_intermed_context
                  before do
                    dict.make_atom_s([cdl, cdr])
                    dict.make_atom_s(cbl)
                    dict.make_atom_s(cbr)
                  end
                  let(:code) do
                    <<-CODE
Atom *atoms2[2] = { atom1, atom2 };
return 0;
                    CODE
                  end
                end
              end
            end
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
              it { expect(expr.code).to eq(code.rstrip) }
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
              it { expect(expr.code).to eq(code.rstrip) }
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
              it { expect(expr.code).to eq(code.rstrip) }
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

          describe '#define_undefined_atoms' do
            include_context :predefined_two_mobs_context
            let(:expr) { subject.define_undefined_atoms(&return0) }

            describe 'all atoms are defined' do
              before { dict.make_atom_s([ctl, ctr]) }
              it { expect(expr.code).to eq('return 0') }
            end

            describe 'one atom is defined' do
              before { dict.make_atom_s(ctr) }
              let(:code) do
                <<-CODE
Atom *atom2 = species1[0]->atom(1);
return 0;
                CODE
              end
              it { expect(expr.code).to eq(code.rstrip) }
            end

            describe 'both atoms are undefined' do
              let(:code) do
                <<-CODE
Atom *atoms1[2] = { species1[0]->atom(1), species1[1]->atom(1) };
return 0;
                CODE
              end
              it { expect(expr.code).to eq(code.rstrip) }
            end
          end

          describe '#define_undefined_species' do
            include_context :rab_context
            let(:expr) { subject.define_undefined_species(&return0) }

            describe 'specie is not defined' do
              before { dict.make_atom_s(cr) }
              let(:code) do
                <<-CODE
Bridge *bridge1 = atom1->specByRole<Bridge>(#{node_specie.source_role(cr)});
if (bridge1)
{
    return 0;
}
                CODE
              end
              it { expect(expr.code).to eq(code.rstrip) }
            end

            describe 'specie already defined' do
              before { dict.make_specie_s(node_specie) }
              it { expect(expr.code).to eq('return 0') }
            end
          end
        end

      end
    end
  end
end
