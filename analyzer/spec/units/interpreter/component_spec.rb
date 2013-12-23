require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Component do
      describe "#interpret" do
        class Some < Component
          def foo(v); v end
          def interpret(line)
            super { |line| pass_line_to(self, line) }
          end
        end

        let(:some) { Some.new }
        it { some.interpret('foo bar').should == 'bar' }
        it { some.interpret('  foo hello').should == 'hello' }
      end
    end

  end
end
