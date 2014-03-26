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
        it { expect(subject.match_used_atom("bridge(:ct)")).to match_array([:bridge, :ct]) }

        ['Wrong', '03001', ''].each do |name|
          atom_str = "#{name}(:ct)"
          it %(wrong spec name "#{name}") do
            expect { subject.match_used_atom(atom_str) }.
              to raise_error *syntax_error(
                'matcher.undefined_used_atom', name: atom_str)
          end
        end

        it "wrong used atom description" do
          expect { subject.match_used_atom("bridge") }.
            to raise_error *syntax_error(
              'matcher.undefined_used_atom', name: 'bridge')
        end
      end
    end

  end
end
