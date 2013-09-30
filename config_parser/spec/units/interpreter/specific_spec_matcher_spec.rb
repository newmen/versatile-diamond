require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe SpecificSpecMatcher, type: :interpreter do
      class SomeMatcher
        include Modules::SyntaxChecker
        include ArgumentsParser
        include SpecificSpecMatcher

        def initialize(&bind_block)
          @bind_block = bind_block
        end

        def match(str)
          match_specific_spec(str, &@bind_block)
        end
      end
      let(:matcher) { SomeMatcher.new { |n| send(:"#{n}_base") } }

      describe "#match_specific_spec" do
        describe "bridge" do
          subject { matcher.match('bridge') }
          it { should be_a(Concepts::SpecificSpec) }
          it { subject.spec.should == bridge_base }
        end

        describe "activated bridge" do
          subject { matcher.match('bridge(ct: *)') }
          it { subject.atom(:ct).should be_a(Concepts::SpecificAtom) }
          it { subject.atom(:ct).actives.should == 1 }
        end

        describe "extra activated bridge" do
          shared_examples_for "different expression" do
            subject { matcher.match(expr) }
            it { subject.atom(:ct).actives.should == 2 }
          end

          it_behaves_like "different expression" do
            let(:expr) { 'bridge(ct: **)' }
          end

          it_behaves_like "different expression" do
            let(:expr) { 'bridge(ct: *, ct: *)' }
          end
        end

        describe "incoherent bridge" do
          subject { matcher.match('bridge(ct: i)') }
          it { subject.atom(:ct).incoherent?.should be_true }
        end

        describe "unfixed methyl" do
          subject { matcher.match('methyl_on_bridge(cm: u)') }
          it { subject.atom(:cm).unfixed?.should be_true }
        end

        describe "just a lot of" do
          subject { matcher.match('methyl_on_bridge(cb: i, cm: u, cm: **)') }
          it { subject.atom(:cb).incoherent?.should be_true }
          it { subject.atom(:cm).unfixed?.should be_true }
          it { subject.atom(:cm).actives.should == 2 }
        end

        describe "wrong specification" do
          it { expect { matcher.match('bridge(:wrong)') }.
            to raise_error *syntax_error(
              'specific_spec.wrong_specification', atom: 'wrong') }

          it { expect { matcher.match('bridge(ct: w)') }.
            to raise_error *syntax_error(
              'specific_spec.wrong_specification', atom: 'ct') }

          it { expect { matcher.match('bridge(ct: ***)') }.
            to raise_error *syntax_error(
              'specific_spec.invalid_actives_num', atom: 'ct', spec: 'bridge')
          }

          it { expect { matcher.match('bridge(ct: *, ct: *, ct: *)') }.
            to raise_error *syntax_error(
              'specific_spec.invalid_actives_num', atom: 'ct', spec: 'bridge')
          }

          it { expect { matcher.match('bridge(ct: i, ct: i)') }.
            to raise_error *syntax_error(
              'specific_spec.atom_already_has_state', state: 'i') }

          it { expect { matcher.match('methyl_on_bridge(cm: u, cm: u)') }.
            to raise_error *syntax_error(
              'specific_spec.atom_already_has_state', state: 'u') }
        end
      end
    end

  end
end
