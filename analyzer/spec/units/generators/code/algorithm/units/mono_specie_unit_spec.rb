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

          describe '#neighbour?' do
            let(:nbr_unit) { described_class.new(dict, nbr_node) }

            describe 'same none specie' do
              include_context :bridge_context
              let(:nbr_node) { ordered_graph.last.first.first }
              it { expect(subject.neighbour?(nbr_unit)).to be_truthy }
            end

            describe 'same not none specie' do
              include_context :top_mob_context
              let(:nbr_nodes) { ordered_graph.last.first.first.split }
              let(:nbr_node) do
                nbr_nodes.find { |n| n.uniq_specie == node_specie }
              end
              it { expect(subject.neighbour?(nbr_unit)).to be_falsey }
            end

            describe 'another not none specie' do
              include_context :alt_intermed_context
              let(:nbr_node) { not_entry_nodes.first }
              it { expect(subject.neighbour?(nbr_unit)).to be_truthy }
            end
          end

          describe '#symmetric?' do
            describe 'realy symmetric' do
              include_context :rab_context
              it { expect(subject.symmetric?).to be_truthy }
            end

            describe 'not symmetric' do
              include_context :mob_context
              it { expect(subject.symmetric?).to be_falsey }
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

          describe '#iterate_specie_symmetries' do
            include_context :rab_context
            before { dict.make_specie_s(node_specie) }
            let(:code) do
              <<-CODE
bridge1->eachSymmetry([](ParentSpec *symmetricBridge1) {
    return 123;
})
              CODE
            end
            let(:expr) { subject.iterate_specie_symmetries(&return123) }
            it { expect(expr.code).to eq(code.rstrip) }
          end
        end

      end
    end
  end
end
