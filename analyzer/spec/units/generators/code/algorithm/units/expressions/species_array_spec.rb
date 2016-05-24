require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe SpeciesArray, type: :algorithm do
          describe '#iterate' do
            include_context :two_mobs_context
            let(:arr) { dict.make_specie_s(unit_nodes.map(&:uniq_specie)) }
            let(:body) { Core::FunctionCall['hello', *arr.items] }
            let(:code) do
              <<-CODE
for (uint s = 0; s < 2; ++s)
{
    hello(species1[s], species1[1 - s]);
}
              CODE
            end
            let(:index) { dict.make_iterator(:s) }
            it { expect(arr.iterate(index, body).code).to eq(code) }
          end
        end

      end
    end
  end
end
