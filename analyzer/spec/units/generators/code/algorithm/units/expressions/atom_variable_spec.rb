require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe AtomVariable, type: :algorithm do
          let(:dict) { VarsDictionary.new }
          let(:var) { dict.make_atom_s(atom, name: 'atom') }

          let(:lattice) do
            Core::ObjectType[unit_nodes.first.lattice_class.class_name]
          end

          let(:actual_role) { subject.actual_role(atom) }
          let(:source_role) { subject.source_role(atom) }

          describe '#define_arg' do
            include_context :unique_parent_context
            let(:atom) { cb }
            it { expect(var.define_arg.code).to eq('Atom *atom1') }
          end

          describe '#role_in' do
            let(:code) { "atom1->is(#{actual_role})" }

            describe 'none specie' do
              include_context :none_specie_context
              let(:atom) { ct }
              it { expect(var.role_in(subject).code).to eq(code) }
            end

            describe 'unique parent' do
              include_context :unique_parent_context
              let(:atom) { cb }
              it { expect(var.role_in(subject).code).to eq(code) }
            end

            describe 'unique reactant' do
              include_context :unique_reactant_context
              let(:atom) { cb }
              it { expect(var.role_in(subject).code).to eq(code) }
            end
          end

          describe '#role_as' do
            include_context :unique_reactant_context
            let(:atom) { cb }
            it { expect(var.role_as(555).code).to eq('atom1->is(555)') }
          end

          describe '#not_found' do
            let(:code) { "!atom1->hasRole(#{enum_name}, #{actual_role})" }

            describe 'none specie' do
              include_context :none_specie_context
              let(:atom) { ct }
              let(:enum_name) { 'BRIDGE' }
              it { expect(var.not_found(subject).code).to eq(code) }
            end

            describe 'unique parent' do
              include_context :unique_parent_context
              let(:atom) { cb }
              let(:enum_name) { 'METHYL_ON_BRIDGE' }
              it { expect(var.not_found(subject).code).to eq(code) }
            end
          end

          describe '#one_specie_by_role' do
            let(:atom) { cb }
            let(:expr) { var.one_specie_by_role(subject) }

            describe 'unique parent' do
              include_context :unique_parent_context
              let(:code) { "atom1->specByRole<Bridge>(#{source_role})" }
              it { expect(expr.code).to eq(code) }
            end

            describe 'unique reactant' do
              include_context :unique_reactant_context
              let(:code) { "atom1->specByRole<MethylOnBridge>(#{source_role})" }
              it { expect(expr.code).to eq(code) }
            end
          end

          describe '#all_species_by_role' do
            shared_examples_for :check_roles_code do
              let(:specie_var) { dict.make_specie_s(subject) }
              let(:body) { Core::Return[specie_var] }
              let(:result) { var.all_species_by_role([], specie_var, body) }
              it { expect(result.code).to eq(code.rstrip) }
            end

            describe 'none specie' do
              include_context :none_specie_context
              it_behaves_like :check_roles_code do
                let(:atom) { ct }
                let(:code) do
                  <<-CODE
atom1->eachSpecByRole<Bridge>(#{source_role}, [](Bridge *bridge1) {
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
atom1->eachSpecByRole<Bridge>(#{source_role}, [](Bridge *bridge1) {
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
atom1->eachSpecByRole<MethylOnBridge>(#{source_role}, [](MethylOnBridge *methylOnBridge1) {
    return methylOnBridge1;
})
                  CODE
                end
              end
            end
          end

          describe '#species_portion_by_role' do
            include_context :two_mobs_context
            subject { node_specie }
            let(:species_arr) { dict.make_specie_s(unit_nodes.map(&:uniq_specie)) }
            let(:body) { Core::Return[species_arr] }
            let(:expr) { var.species_portion_by_role([], species_arr, body) }

            let(:atom) { cm }
            let(:code) do
              <<-CODE
atom1->eachSpecsPortionByRole<MethylOnBridge>(#{source_role}, 2, [](MethylOnBridge **species1) {
    return species1;
})
              CODE
            end
            it { expect(expr.code).to eq(code.rstrip) }
          end

          describe '#has_bond_with' do
            include_context :alt_two_mobs_context
            let(:atoms) { dict.make_atom_s(unit_nodes.map(&:atom)).items }
            let(:expr) { atoms.first.has_bond_with(atoms.last) }
            it { expect(expr.code).to eq('atoms1[0]->hasBondWith(atoms1[1])') }
          end

          describe '#iterate_amorph_nbrs' do
            include_context :mob_context
            let(:atom_var) { dict.make_atom_s(cb) }
            let(:nbr_var) { dict.make_atom_s(cm) }
            let(:body) { Core::Return[nbr_var] }
            let(:code) do
              <<-CODE
atom1->eachAmorphNeighbour([](Atom *amorph1) {
    return amorph1;
})
              CODE
            end
            let(:expr) { atom_var.iterate_amorph_nbrs([], nbr_var, body) }
            it { expect(expr.code).to eq(code.rstrip) }
          end

          describe '#iterate_crystal_nbrs' do
            include_context :mob_context
            let(:atom_var) { dict.make_atom_s(cm) }
            let(:nbr_var) { dict.make_atom_s(cb) }
            let(:body) { Core::Return[nbr_var] }
            let(:code) do
              <<-CODE
amorph1->eachCrystalNeighbour([](Atom *atom1) {
    return atom1;
})
              CODE
            end
            let(:expr) { atom_var.iterate_crystal_nbrs([], nbr_var, body) }
            it { expect(expr.code).to eq(code.rstrip) }
          end

          describe '#iterate_over_lattice' do
            include_context :alt_intermed_context
            let(:atom_var) { dict.make_atom_s(cbr) }
            let(:nbr_var) { dict.make_atom_s(cdr) }
            let(:rel_params) { param_100_front }
            let(:body) { Core::Return[nbr_var] }
            let(:code) do
              <<-CODE
eachNeighbour(atom1, &Diamond::front_100, [](Atom *atom2) {
    return atom2;
})
              CODE
            end
            let(:expr) do
              atom_var.iterate_over_lattice([], nbr_var, lattice, rel_params, body)
            end
            it { expect(expr.code).to eq(code.rstrip) }
          end

          describe '#all_crystal_nbrs' do
            include_context :bridge_context
            let(:atom_var) { dict.make_atom_s(ct) }
            let(:nbrs_arr) { dict.make_atom_s([cl, cr]) }
            let(:rel_params) { param_110_cross }
            let(:body) { Core::Return[nbrs_arr] }
            let(:code) do
              <<-CODE
allNeighbours(atom1, &Diamond::cross_110, [](Atom **atoms1) {
    return atoms1;
})
              CODE
            end
            let(:expr) do
              atom_var.all_crystal_nbrs([], nbrs_arr, lattice, rel_params, body)
            end
            it { expect(expr.code).to eq(code.rstrip) }
          end

          describe '#crystal' do
            include_context :unique_reactant_context
            let(:atom) { cb }
            it { expect(var.crystal.code).to eq('crystalBy(atom1)') }
          end

          describe '#coords_with' do
            include_context :bridge_context
            let(:atom) { dict.make_atom_s(cr) }
            let(:other) { dict.make_atom_s(cl) }
            let(:coords) { atom.coords_with(other, lattice, param_110_front) }
            let(:code) { 'Diamond::front_110_at(atom1, atom2)' }
            it { expect(coords.code).to eq(code) }
          end

          describe '#insert_to_amorph' do
            include_context :unique_reactant_context
            let(:atom) { cb }
            let(:code) { 'Handbook::amorph().insert(atom1)' }
            it { expect(var.insert_to_amorph.code).to eq(code) }
          end

          describe '#insert_to_crystal' do
            include_context :bridge_context
            let(:atom) { dict.make_atom_s(cr) }
            let(:other) { dict.make_atom_s(cl) }
            let(:crystal) { atom.crystal }
            let(:coords) { atom.coords_with(other, lattice, param_110_front) }
            let(:code) do
              'crystalBy(atom1)->insert(atom1, Diamond::front_110_at(atom1, atom2))'
            end
            it { expect(atom.insert_to_crystal(crystal, coords).code).to eq(code) }
          end

          describe '#erase_from_amorph' do
            include_context :unique_reactant_context
            let(:atom) { cm }
            let(:code) { 'Handbook::amorph().erase(atom1)' }
            it { expect(var.erase_from_amorph.code).to eq(code) }
          end

          describe '#erase_from_crystal' do
            include_context :unique_reactant_context
            let(:atom) { cb }
            let(:code) { 'atom1->lattice()->crystal()->erase(atom1)' }
            it { expect(var.erase_from_crystal.code).to eq(code) }
          end

          describe '#recharge' do
            include_context :unique_reactant_context
            let(:atom) { cm }
            it { expect(var.recharge(1).code).to eq('atom1->activate()') }
            it { expect(var.recharge(-1).code).to eq('atom1->deactivate()') }

            let(:many_code) do
              <<-CODE
atom1->activate();
atom1->activate();
atom1->activate();
              CODE
            end
            it { expect(var.recharge(3).code).to eq(many_code.rstrip) }
          end

          describe '#bond_with' do
            include_context :bridge_context
            let(:atom) { dict.make_atom_s(cr) }
            let(:other) { dict.make_atom_s(cl) }
            let(:code) { 'atom1->bondWith(atom2)' }
            it { expect(atom.bond_with(other).code).to eq(code) }
          end

          describe '#unbond_from' do
            include_context :bridge_context
            let(:atom) { dict.make_atom_s(cr) }
            let(:other) { dict.make_atom_s(cl) }
            let(:code) { 'atom1->unbondFrom(atom2)' }
            it { expect(atom.unbond_from(other).code).to eq(code) }
          end

          describe '#change_role' do
            include_context :unique_reactant_context
            let(:atom) { cb }
            it { expect(var.change_role(777).code).to eq('atom1->changeType(777)') }
          end

          describe '#mark_to_remove' do
            include_context :unique_reactant_context
            let(:atom) { cm }
            let(:code) { 'Handbook::scavenger().markAtom(atom1)' }
            it { expect(var.mark_to_remove.code).to eq(code) }
          end
        end

      end
    end
  end
end
