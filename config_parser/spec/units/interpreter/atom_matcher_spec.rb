require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe AtomMatcher, type: :interpreter do
      class SomeMatcher
        include Modules::SyntaxChecker
        include AtomMatcher
      end
      subject { SomeMatcher.new }

      describe "#match_used_atom" do
        it { subject.match_used_atom("bridge(:ct)").should == [:bridge, :ct] }

        ['Wrong', '03001', ''].each do |name|
          it %(wrong spec name "#{name}") do
            expect { subject.match_used_atom("#{name}(:ct)") }.
              to raise_error syntax_error
          end
        end

        it "wrong used atom description" do
          expect { subject.match_used_atom("bridge") }.
            to raise_error syntax_error
        end
      end
    end

  end
end
