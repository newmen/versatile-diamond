require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe ManySpecieUnits, type: :algorithm do
          subject { described_class.new(dict, units) }
          let(:units) do
            unit_nodes.map { |node| MonoPureUnit.new(dict, node) }
          end

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
            it { expect(subject.units).to eq(units) }
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
              it { expect(subject.filled_inner_units).to eq([units.first]) }
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
              before { dict.make_specie_s(unit_nodes.map(&:uniq_specie)) }
              it { expect(subject.checkable?).to be_falsey }
            end
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
        end

      end
    end
  end
end
