require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe ComplexComponent do
      describe "#interpret" do
        class Simple < Component
          def initialize(tail); @tail = tail end
          def tail_with(v); "#{@tail} #{v}" end
        end

        class Complex < ComplexComponent
          def foo(tail); tail end
          def simple(tail); nested(Simple.new(tail)) end
          def other(tail); nested(Simple.new(tail)) end
        end

        let(:complex) { Complex.new }

        it { complex.interpret('foo tail').should == 'tail' }
        it { complex.interpret('simple hello').should be_a(Simple) }

        it "passes line to nested if has indent" do
          complex.interpret('simple story')
          complex.interpret('  tail_with end').should == 'story end'
        end

        it "switch to another nested component" do
          complex.interpret('simple story')
          complex.interpret('other example')
          complex.interpret('  tail_with it').should == 'example it'
        end

        it "indent without nested raise syntax error" do
          -> { complex.interpret('  foo wrong').should }.
            should raise_error Errors::SyntaxError
        end
      end
    end

  end
end