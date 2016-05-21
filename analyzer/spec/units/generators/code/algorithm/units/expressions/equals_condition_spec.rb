require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe EqualsCondition, type: :algorithm do
          include_context :unique_parent_context

          let(:dict) { VarsDictionary.new }
          let(:body) { Core::FunctionCall['hello', *arr.items] }
          let(:arr) { dict.make_atom_s([cb, cm], name: 'atoms') }
          subject { described_class[exprs_pairs, body] }

          describe 'just one pair' do
            let(:exprs_pairs) { [arr.items] }
            let(:code) do
              <<-CODE
if (atoms1[0] == atoms1[1])
{
    hello(atoms1[0], atoms1[1]);
}
              CODE
            end
            it { expect(subject.code).to eq(code) }
          end

          describe 'two pairs' do
            let(:specie_var) { dict.make_specie_s(uniq_parent_inst) }
            let(:exprs_pairs) do
              [[specie_var.atom_value(cb), arr.items.first], arr.items]
            end
            let(:code) do
              <<-CODE
if (atoms1[0] == atoms1[1] && atoms1[0] == bridge1->atom(0))
{
    hello(atoms1[0], atoms1[1]);
}
              CODE
            end
            it { expect(subject.code).to eq(code) }
          end
        end

      end
    end
  end
end
