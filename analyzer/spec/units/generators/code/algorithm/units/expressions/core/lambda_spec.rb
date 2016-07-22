require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Lambda do
          subject { lda }

          include_context :predefined_exprs
          let(:is_expr) { true }
          let(:is_const) { true }

          describe '#self.[]' do
            describe 'wrong vars' do
              it { expect { described_class[[], func0] }.not_to raise_error }

              it { expect { described_class[nil, func0] }.to raise_error }
              it { expect { described_class[[], type, func1] }.to raise_error }
              it { expect { described_class[[], x, func2] }.to raise_error }
            end
          end

          it_behaves_like :check_predicates

          describe '#code' do
            describe 'without predefined vars' do
              let(:code) do
                <<-CODE
[](Yo *obj) {
    simple();
    simple();
}
                CODE
              end
              it { expect(subject.code).to eq(code.rstrip) }
            end

            describe 'with predefined vars' do
              subject { Lambda[defined_vars, var, body] }
              let(:this) { This[:this, 'Some'] }
              let(:body) { var.call('hello', this, inst) }

              describe 'with not using variable' do
                let(:defined_vars) { [inst, this, scv] }
                let(:code) do
                  <<-CODE
[&this, &inst](Yo *obj) {
    obj->hello(this, inst);
}
                  CODE
                end
                it { expect(subject.code).to eq(code.rstrip) }
              end

              describe 'all variables are used' do
                let(:defined_vars) { [inst, this] }
                let(:code) do
                  <<-CODE
[&](Yo *obj) {
    obj->hello(this, inst);
}
                  CODE
                end
                it { expect(subject.code).to eq(code.rstrip) }
              end
            end
          end
        end

      end
    end
  end
end
