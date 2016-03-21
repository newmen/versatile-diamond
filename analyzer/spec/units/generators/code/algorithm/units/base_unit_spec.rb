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
            include_context :two_mobs_context
            let(:prc) do
              -> { Expressions::Core::Return[Expressions::Core::Constant[0]] }
            end

            describe 'one atom' do
              before { dict.make_atom_s(cm) }
              let(:code) do
                <<-CODE
if (amorph1->is(#{node_specie.actual_role(cm)}))
{
    return 0;
}
                CODE
              end
              it { expect(subject.check_atoms_roles([cm], &prc).code).to eq(code) }
            end
          end
        end

      end
    end
  end
end
