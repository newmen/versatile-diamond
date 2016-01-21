module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core
        module Support

          module StatementsExamples
            shared_context :predefined_exprs do
              let(:namer) { Algorithm::Units::NameRemember.new }

              let(:x) { Constant['x'] }
              let(:y) { Constant['y'] }
              let(:type) { Type['Yo'] }
              let(:num) { Constant[5] }
              let(:var) { Variable[namer, Object.new, type, 'obj'] }

              let(:func0) { FunctionCall['simple'] }
              let(:func1) { FunctionCall['mono', x] }
              let(:func2) { FunctionCall['many', x, y] }
              let(:tfunc0) { FunctionCall['templ', template_args: [type, num]] }
              let(:method) { FunctionCall['method', num, target: var] }
            end

            shared_examples_for :check_const_init do
              describe 'side spaces' do
                it { expect { described_class[' '] }.to raise_error }
                it { expect { described_class[' hello'] }.to raise_error }
                it { expect { described_class['world '] }.to raise_error }
                it { expect { described_class["\t"] }.to raise_error }
                it { expect { described_class["\n"] }.to raise_error }
              end

              describe 'wrong type' do
                it { expect { described_class[Object.new] }.to raise_error }
                it { expect { described_class[Array.new] }.to raise_error }
                it { expect { described_class[Hash.new] }.to raise_error }
                it { expect { described_class[Set.new] }.to raise_error }
              end
            end

            shared_examples_for :check_expr_init do
              it_behaves_like :check_const_init

              describe 'side spaces' do
                it { expect { described_class[''] }.to raise_error }
              end

              describe 'wrong type' do
                it { expect { described_class[123] }.to raise_error }
                it { expect { described_class[2.71] }.to raise_error }
              end
            end
          end

        end
      end
    end
  end
end
