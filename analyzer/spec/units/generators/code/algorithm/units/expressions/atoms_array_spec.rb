require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe AtomsArray, type: :algorithm do
          let(:dict) { VarsDictionary.new }
          let(:var) { dict.make_atom_s(atoms, name: 'atoms') }

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
        end

      end
    end
  end
end
