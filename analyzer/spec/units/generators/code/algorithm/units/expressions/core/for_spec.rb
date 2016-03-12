require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe For do
          subject { for_loop }

          include_context :predefined_exprs
          it_behaves_like :check_predicates

          describe '#code' do
            let(:code) do
              <<-CODE
for (int i = 0; i < 3; ++i)
{
    simple();
    mono(x);
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
