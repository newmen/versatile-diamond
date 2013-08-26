require 'spec_helper'

module VersatileDiamond
  module Modules

    describe SyntaxChecker do
      class SomeChecker
        include SyntaxChecker
      end
      subject { SomeChecker.new }
      let(:syntax_error) { Errors::SyntaxError }

      describe "#syntax_error" do
        it { expect { subject.syntax_error('hello') }.
          to raise_error syntax_error }

        it "validate message" do
          begin
            subject.syntax_error('.hello', name: 'World')
          rescue syntax_error => e
            e.message('/path', 0).should == "Hello, World!\n\tfrom /path:0"
          end
        end
      end
    end

  end
end
