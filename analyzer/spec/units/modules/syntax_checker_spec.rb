require 'spec_helper'

module VersatileDiamond
  module Modules

    describe SyntaxChecker do
      class SomeChecker
        include SyntaxChecker
      end
      subject { SomeChecker.new }

      describe "#syntax_error" do
        let(:syntax_error) { Errors::SyntaxError }

        it { expect { subject.syntax_error('hello') }.
          to raise_error syntax_error }

        it "validate message" do
          begin
            subject.syntax_error('.hello', name: 'World')
          rescue syntax_error => e
            expect(e.message('/path', 0)).to eq("Hello, World!\n\tfrom /path:0")
          end
        end
      end

      describe "#syntax_warning" do
        let(:syntax_warning) { Errors::SyntaxWarning }

        it { expect { subject.syntax_warning('warning') }.
          to raise_error syntax_warning }

        it "validate message" do
          begin
            subject.syntax_warning('.warning', param: 'message')
          rescue syntax_warning => e
            expect(e.message).to eq("Warning! Test message (skipped)")
          end
        end
      end
    end

  end
end
