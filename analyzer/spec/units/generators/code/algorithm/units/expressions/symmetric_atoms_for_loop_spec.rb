require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe SymmetricAtomsForLoop, type: :algorithm do
          include_context :unique_parent_context
          let(:dict) { VarsDictionary.new }

          let(:vars) { dict.make_atom_s([cb, cm], name: 'atoms') }
          let(:body) { Core::FunctionCall['hello', *vars.items] }
          subject { described_class[vars.items, body] }

          describe '#code' do
            let(:code) do
              <<-CODE
for (uint a = 0; a < 2; ++a)
{
    hello(atoms1[a], atoms1[1 - a]);
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
