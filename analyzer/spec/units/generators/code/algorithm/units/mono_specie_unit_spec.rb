require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe MonoSpecieUnit, type: :algorithm do
          subject { described_class.new(dict, node) }
          let(:node) { unit_nodes.first }

          let(:return123) do
            -> { Expressions::Core::Return[Expressions::Core::Constant[123]] }
          end

          describe '#define!' do
            before { subject.define! }

            describe 'no parents' do
              include_context :bridge_context
              let(:var) { dict.var_of(ct) }
              it { expect(var.code).to eq('anchor') }
            end

            describe 'just one parent' do
              include_context :rab_context
              let(:var) { dict.var_of(node_specie) }
              it { expect(var.code).to eq('parent') }
            end

            # realy case?
            describe 'many parents' do
              include_context :two_mobs_context
              let(:var) { dict.var_of(cm) }
              it { expect(var.code).to eq('anchor') }
            end
          end

          describe '#units' do
            include_context :rab_context
            it { expect(subject.units).to eq([subject]) }
          end

          describe '#filled_inner_units' do
            include_context :rab_context

            describe 'predefined specie' do
              before { subject.define! }
              it { expect(subject.filled_inner_units).to eq([subject]) }
            end

            describe 'predefined atom' do
              before { dict.make_atom_s(node.atom) }
              it { expect(subject.filled_inner_units).to eq([subject]) }
            end

            describe 'specie and atom are not defined' do
              it { expect(subject.filled_inner_units).to be_empty }
            end
          end

          describe '#checkable?' do
            describe 'root specie' do
              include_context :bridge_context

              describe 'undefined species' do
                it { expect(subject.checkable?).to be_falsey }
              end

              describe 'all species are defined' do
                before { dict.make_specie_s(node_specie) }
                it { expect(subject.checkable?).to be_falsey }
              end
            end

            describe 'anchored species have a parent' do
              include_context :rab_context

              describe 'undefined species' do
                it { expect(subject.checkable?).to be_truthy }
              end

              describe 'all species are defined' do
                before { dict.make_specie_s(node_specie) }
                it { expect(subject.checkable?).to be_falsey }
              end
            end

            describe 'no anchored species' do
              include_context :intermed_context
              let(:node) { not_entry_nodes.first }

              describe 'undefined species' do
                it { expect(subject.checkable?).to be_falsey }
              end

              describe 'all species are defined' do
                before { dict.make_specie_s(node.uniq_specie) }
                it { expect(subject.checkable?).to be_falsey }
              end
            end
          end

          describe '#check_different_atoms_roles' do
            include_context :rab_context

            before do
              dict.make_specie_s(node_specie)
              dict.make_atom_s(cr)
            end

            let("role_cr") { node_specie.actual_role(cr) }
            let(:expr) { subject.check_different_atoms_roles(&return123) }
            let(:code) do
              <<-CODE
if (atom1->is(#{role_cr}))
{
    return 123;
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
