require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Assign do
          subject { assign }

          include_context :predefined_exprs
          let(:is_assign) { true }

          describe '#self.[]' do
            it { expect { described_class[x, y] }.to raise_error }
            it { expect { described_class[x] }.to raise_error }
            it { expect { described_class[type, type: type] }.to raise_error }
            it { expect { described_class[x, type: x] }.to raise_error }
            it { expect { described_class[x, value: subject] }.to raise_error }
            it { expect { described_class[ret, value: x] }.to raise_error }

            let(:wrong_assert) { described_class[x, type: type.ptr, value: num] }
            it { expect { wrong_assert }.to raise_error }
          end

          it_behaves_like :check_predicates

          describe '#code' do
            it { expect(subject.code).to eq('Yo *x = y') }

            describe 'scalar type and value'
            it { expect(Assign[x, type: type, value: num].code).to eq('Yo x = 5') }
          end
        end

      end
    end
  end
end
