require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe ArgumentsParser, type: :interpreter do
      class Parser
        include Modules::SyntaxChecker
        include ArgumentsParser
      end
      subject { Parser.new }

      shared_examples_for "checks wrong ordering" do
        it "wrong arguments ordering" do
          expect { subject.send(method, 'one: 2, :three') }.
            to raise_error *syntax_error('common.wrong_arguments_ordering')
        end
      end

      describe "#string_to_args" do
        it { subject.string_to_args('').should == [] }
        it { subject.string_to_args('one').should == ['one'] }
        it { subject.string_to_args(':one, 2').should == [:one, 2] }
        it { subject.string_to_args('1, two: 3').should == [1, { two: 3 }] }
        it { subject.string_to_args('one: 2, three: 4').
          should == [{ one: 2, three: 4 }] }

        it "options key duplication" do
          expect { subject.string_to_args(':one, two: 3, two: 4') }.
            to raise_error *syntax_error('common.duplicating_key', name: 'two')
        end

        it_behaves_like "checks wrong ordering" do
          let(:method) { :string_to_args }
        end
      end

      describe "#extract_hash_args" do
        it { subject.extract_hash_args(':one, 2, three: 4').
          should == [:one, 2] }

        it "pass each pair to block" do
          pairs = {}
          subject.extract_hash_args('1, two: 3, four: 5') do |k, v|
            pairs[k] = v
          end
          pairs.should == { two: 3, four: 5 }
        end

        it_behaves_like "checks wrong ordering" do
          let(:method) { :extract_hash_args }
        end
      end
    end

  end
end
