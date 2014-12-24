require 'spec_helper.rb'

module VersatileDiamond
  module Interpreter

    describe Base do
      let(:base) { described_class.new }

      describe '#interpret' do
        def interpret_line(line)
          base.interpret(line, -> _ { :no_indent }, &-> _ { :indent })
        end

        it { expect(interpret_line('hello')).to eq(:no_indent) }
        it { expect(interpret_line('  hello')).to eq(:indent) }
        it { expect(interpret_line("\thello")).to eq(:indent) }

        let(:syntax_error) { Errors::SyntaxError }

        it { expect { interpret_line(' hello') }.to raise_error syntax_error }
        it { expect { interpret_line('   hello') }.
          to raise_error syntax_error }

        it 'line with ident and havent block' do
          expect { base.interpret('  hello', -> _ {}) }.
            to raise_error syntax_error
        end
      end

      describe '#head_and_tail' do
        let(:hat) { base.head_and_tail('hello the great world!') }
        it { expect(hat.first).to eq('hello') }
        it { expect(hat.last).to eq('the great world!') }
      end

      describe '#pass_line_to' do
        class Child < Base
          def interpret(line)
            super(line, -> _ { line.strip }) do |line|
              pass_line_to(self, line)
            end
          end
        end

        it { expect(base.pass_line_to(Child.new, '  hello')).to eq('hello') }
        it { expect(base.pass_line_to(Child.new, '    hello')).to eq('hello') }
      end
    end

  end
end