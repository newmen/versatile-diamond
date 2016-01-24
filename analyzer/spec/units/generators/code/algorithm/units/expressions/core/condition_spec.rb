require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Condition do
          subject { small_cond }

          include_context :predefined_exprs
          let(:is_cond) { true }

          describe '#self.[]' do
            it { expect { described_class[x] }.to raise_error }
            it { expect { described_class[type] }.to raise_error }
            it { expect { described_class[type, x] }.to raise_error }
            it { expect { described_class[x, type] }.to raise_error }
            it { expect { described_class[x, y, type] }.to raise_error }
          end

          it_behaves_like :check_predicates

          describe '#code' do
            it { expect(subject.code).to eq("if (x || y)\n{\n    many(x, y);\n}\n") }
            it { expect(big_cond.code).to eq(big_code) }
            let(:big_code) do
              "if (x && y)\n{\n    many(x, y);\n}\nelse\n{\n    simple();\n}\n"
            end
          end
        end

      end
    end
  end
end
