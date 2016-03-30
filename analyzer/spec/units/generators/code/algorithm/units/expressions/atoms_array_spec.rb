require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe AtomsArray, type: :algorithm do
          let(:dict) { VarsDictionary.new }
          let(:var) { dict.make_atom_s(atoms, name: 'atoms') }

          let(:lattice) do
            Core::ObjectType[unit_nodes.first.lattice_class.class_name]
          end

          describe '#define_arg' do
            include_context :unique_parent_context
            let(:var) { dict.make_atom_s([cb, cm], name: 'as') }
            it { expect(var.define_arg.code).to eq('Atom **as1') }
          end

          describe '#each' do
            include_context :unique_parent_context
            let(:arr) { dict.make_atom_s([cb, cm]) }
            let(:body) { Core::FunctionCall['hello', *arr.items] }
            let(:code) do
              <<-CODE
for (uint a = 0; a < 2; ++a)
{
    hello(atoms1[a], atoms1[1 - a]);
}
              CODE
            end
            it { expect(arr.each(body).code).to eq(code) }
          end

          describe '#iterate_over_lattice' do
            include_context :half_intermed_context
            let(:atoms_arr) { dict.make_atom_s([cdl, cdr]) }
            let(:nbrs_arr) { dict.make_atom_s([cbl, cbr]) }
            let(:rel_params) { param_100_cross }
            let(:body) { Core::Return[nbrs_arr] }
            let(:code) do
              <<-CODE
eachNeighbours<2>(atoms1, &Diamond::cross_100, [](Atom **atoms2) {
    return atoms2;
})
              CODE
            end
            let(:expr) do
              atoms_arr.iterate_over_lattice([], nbrs_arr, lattice, rel_params, body)
            end
            it { expect(expr.code).to eq(code.rstrip) }
          end

          describe '#nbr_from' do
            include_context :alt_bridge_context
            let(:atoms_arr) { dict.make_atom_s([cl, cr]) }
            let(:nbr_var) { dict.make_atom_s(ct) }
            let(:rel_params) { param_110_front }
            let(:body) { Core::Return[nbr_var] }
            let(:code) do
              <<-CODE
neighbourFrom(atoms1, &Diamond::front_110_at, [](Atom *atom1) {
    return atom1;
})
              CODE
            end
            let(:expr) do
              atoms_arr.nbr_from([], nbr_var, lattice, rel_params, body)
            end
            it { expect(expr.code).to eq(code.rstrip) }
          end
        end

      end
    end
  end
end
