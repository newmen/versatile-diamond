require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe AndCondition, type: :algorithm do
          include_context :unique_parent_context

          let(:dict) { VarsDictionary.new }
          let(:body) { Core::FunctionCall['hello'] }
          subject { described_class[exprs, body] }

          describe 'just one pair' do
            let(:exprs) { [dict.make_atom_s(cb)] }
            let(:code) do
              <<-CODE
if (atom1)
{
    hello();
}
              CODE
            end
            it { expect(subject.code).to eq(code) }
          end

          describe 'two pairs' do
            let(:exprs) { dict.make_atom_s([cm, cb]).items }
            let(:code) do
              <<-CODE
if (atoms1[0] && atoms1[1])
{
    hello();
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
