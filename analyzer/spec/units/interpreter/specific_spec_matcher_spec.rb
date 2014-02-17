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

      let(:matcher) { SomeMatcher.new { |name| send(:"#{name}_base") } }

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

        describe "right atom of bridge is hydride" do
          before(:each) { Tools::Chest.store(h) }
          subject { matcher.match('bridge(cr: H)') }
          it { subject.atom(:cr).monovalents.should == [:H] }
          it { subject.atom(:cl).monovalents.should be_empty }
        end

        describe "just a lot of" do
          before(:each) { Tools::Chest.store(cl) }
          subject { matcher.match('methyl_on_bridge(cb: i, cm: u, cm: **, cm: Cl)') }
          it { subject.atom(:cb).incoherent?.should be_true }
          it { subject.atom(:cm).unfixed?.should be_true }
          it { subject.atom(:cm).actives.should == 2 }
          it { subject.atom(:cm).monovalents.should == [:Cl] }
        end

        describe "wrong specification" do
          it "invalid options" do
            expect { matcher.match('bridge(:wrong)') }.
              to raise_error *syntax_error(
                'specific_spec.wrong_specification', atom: 'wrong')
          end

          it "invalid valence" do
            expect { matcher.match('bridge(ct: ***)') }.
              to raise_error *syntax_error(
                'specific_spec.atom_invalid_bonds_num', atom: 'ct', spec: 'bridge')
          end

          it "invalid valence too" do
            expect { matcher.match('bridge(ct: *, ct: *, ct: *)') }.
              to raise_error *syntax_error(
                'specific_spec.atom_invalid_bonds_num', atom: 'ct', spec: 'bridge')
          end

          it "twise incoherent" do
            expect { matcher.match('bridge(ct: i, ct: i)') }.
              to raise_error *syntax_error(
                'specific_spec.atom_already_has_state', state: 'i')
          end

          it "twise unfixed" do
            expect { matcher.match('methyl_on_bridge(cm: u, cm: u)') }.
              to raise_error *syntax_error(
                'specific_spec.atom_already_has_state', state: 'u')
          end

          describe "wrong value" do
            before(:each) do
              Tools::Chest.store(h)
              Tools::Chest.store(o)
            end

            it "invalid keyname" do
              expect { matcher.match('bridge(ct: w)') }.
                to raise_error *syntax_error(
                  'specific_spec.wrong_specification', atom: 'ct')
            end

            it "cannot use not monovalent atom" do
              expect { matcher.match('bridge(ct: O)') }.
                to raise_error *syntax_error(
                  'specific_spec.wrong_specification', atom: 'ct')
            end

            it "cannot be hydride" do
              expect { matcher.match('bridge(ct: **, ct: H)') }.
                to raise_error *syntax_error(
                  'specific_spec.atom_invalid_bonds_num', atom: 'ct', spec: 'bridge')
            end
          end
        end
      end
    end

  end
end
