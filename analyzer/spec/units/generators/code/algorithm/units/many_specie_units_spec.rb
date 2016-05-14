require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe ManySpecieUnits, type: :algorithm do
          def nodes_to_mono_units(nodes)
            nodes.map { |node| MonoSpecieUnit.new(dict, node) }
          end

          def nodes_to_many_units(nodes)
            described_class.new(dict, nodes_to_mono_units(nodes))
          end

          subject { nodes_to_many_units(unit_nodes) }

          let(:return456) do
            -> { Expressions::Core::Return[Expressions::Core::Constant[456]] }
          end

          describe '#define!' do
            before { subject.define! }

            describe 'just one specie' do
              include_context :incoherent_dimer_context
              let(:var) { dict.var_of(node_specie) }
              it { expect(var.code).to eq('parent') }
            end

            describe 'just one atom' do
              include_context :two_mobs_context
              let(:var) { dict.var_of(cm) }
              it { expect(var.code).to eq('anchor') }
            end
          end

          describe '#units' do
            include_context :two_mobs_context
            it 'inner units are mono all' do
              expect(subject.units.size).to eq(2)
              expect(subject.units.flat_map(&:nodes)).to match_array(unit_nodes)
            end
          end

          describe '#filled_inner_units' do
            include_context :two_mobs_context

            describe 'predefined atom' do
              before { subject.define! }
              it { expect(subject.filled_inner_units).to eq([subject]) }
            end

            describe 'predefined species' do
              before { dict.make_specie_s(subject.species) }
              it { expect(subject.filled_inner_units).to eq([subject]) }
            end

            describe 'just one specie is predefined' do
              before { dict.make_specie_s(subject.species.first) }
              it { expect(subject.filled_inner_units).to eq([subject.units.first]) }
            end

            describe 'species and atom are not defined' do
              it { expect(subject.filled_inner_units).to be_empty }
            end
          end

          describe '#checkable?' do
            include_context :two_mobs_context

            describe 'undefined species' do
              it { expect(subject.checkable?).to be_truthy }
            end

            describe 'all species are defined' do
              before { dict.make_specie_s(unit_species) }
              it { expect(subject.checkable?).to be_falsey }
            end
          end

          describe '#neighbour?' do
            include_context :alt_two_mobs_context
            let(:nbr_unit) { nodes_to_many_units(nbr_nodes) }
            let(:nbr_nodes) { entry_nodes.first.split }
            it { expect(subject.neighbour?(nbr_unit)).to be_falsey }
          end

          describe '#partially_symmetric?' do
            include_context :alt_two_mobs_context
            it { expect(subject.partially_symmetric?).to be_falsey }
          end

          describe '#check_different_atoms_roles' do
            include_context :incoherent_dimer_context

            before do
              dict.make_specie_s(node_specie)
              dict.make_atom_s([cl, cr])
            end

            let("role_cr") { node_specie.actual_role(cr) }
            let(:expr) { subject.check_different_atoms_roles(&return456) }
            let(:code) do
              <<-CODE
if (atoms1[0]->is(#{role_cr}) && atoms1[1]->is(#{role_cr}))
{
    return 456;
}
              CODE
            end
            it { expect(expr.code).to eq(code) }
          end

          describe '#iterate_species_by_role' do
            include_context :two_mobs_context
            before { dict.make_atom_s(cm) }

            let(:role_cm) { node_specie.source_role(cm) }
            let(:unit_nodes) { [entry_nodes.first.split.first] } # override
            let(:code) do
              <<-CODE
amorph1->eachSpecByRole<MethylOnBridge>(#{role_cm}, [](MethylOnBridge *methylOnBridge1) {
    return 456;
})
              CODE
            end
            let(:expr) { subject.iterate_species_by_role(&return456) }
            it { expect(expr.code).to eq(code.rstrip) }
          end

          describe '#iterate_portions_of_similar_species' do
            include_context :two_mobs_context
            before { dict.make_atom_s(cm) }

            let(:role_cm) { node_specie.source_role(cm) }
            let(:code) do
              <<-CODE
amorph1->eachSpecsPortionByRole<MethylOnBridge>(#{role_cm}, 2, [](MethylOnBridge **species1) {
    return 456;
})
              CODE
            end
            let(:expr) { subject.iterate_portions_of_similar_species(&return456) }
            it { expect(expr.code).to eq(code.rstrip) }
          end

          describe '#iterate_species_by_loop' do
            include_context :two_mobs_context
            before { dict.make_specie_s(unit_species) }
            let(:code) do
              <<-CODE
for (uint s = 0; s < 2; ++s)
{
    return 456;
}
              CODE
            end
            it { expect(subject.iterate_species_by_loop(&return456).code).to eq(code) }
          end
        end

      end
    end
  end
end
