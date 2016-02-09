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
              "for (int i1 = 0; i1 < 3; ++i1)\n{\n    simple();\n    mono(x);\n}\n"
            end
            it { expect(subject.code).to eq(code) }
          end
        end

      end
    end
  end
end
