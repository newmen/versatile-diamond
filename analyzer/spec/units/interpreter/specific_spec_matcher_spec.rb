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

      describe '#match_specific_spec' do
        describe 'bridge' do
          subject { matcher.match('bridge') }
          it { should be_a(Concepts::SpecificSpec) }
          it { expect(subject.spec).to eq(bridge_base) }
        end

        describe 'activated bridge' do
          subject { matcher.match('bridge(ct: *)') }
          it { expect(subject.atom(:ct)).to be_a(Concepts::SpecificAtom) }
          it { expect(subject.atom(:ct).actives).to eq(1) }
        end

        describe 'extra activated bridge' do
          shared_examples_for 'different expression' do
            subject { matcher.match(expr) }
            it { expect(subject.atom(:ct).actives).to eq(2) }
          end

          it_behaves_like 'different expression' do
            let(:expr) { 'bridge(ct: **)' }
          end

          it_behaves_like 'different expression' do
            let(:expr) { 'bridge(ct: *, ct: *)' }
          end
        end

        describe 'incoherent bridge' do
          subject { matcher.match('bridge(ct: i)') }
          it { expect(subject.atom(:ct).incoherent?).to be_true }
        end

        describe 'unfixed methyl' do
          subject { matcher.match('methyl_on_bridge(cm: u)') }
          it { expect(subject.atom(:cm).unfixed?).to be_true }
        end

        describe 'right atom of bridge is hydride' do
          before(:each) { Tools::Chest.store(h) }
          subject { matcher.match('bridge(cr: H)') }
          it { expect(subject.atom(:cr).monovalents).to eq([:H]) }
          it { expect(subject.atom(:cl).monovalents).to be_empty }
        end

        describe 'just a lot of' do
          subject do
            matcher.match('methyl_on_bridge(cb: i, cm: u, cm: **, cm: Cl)')
          end

          before(:each) { Tools::Chest.store(cl) }

          it { expect(subject.atom(:cb).incoherent?).to be_true }
          it { expect(subject.atom(:cm).unfixed?).to be_true }
          it { expect(subject.atom(:cm).actives).to eq(2) }
          it { expect(subject.atom(:cm).monovalents).to eq([:Cl]) }
        end

        describe 'wrong specification' do
          it 'invalid options' do
            expect { matcher.match('bridge(:wrong)') }.
              to raise_error(*syntax_error(
                'specific_spec.wrong_specification', atom: 'wrong'))
          end

          it 'invalid valence' do
            expect { matcher.match('bridge(ct: ***)') }.
              to raise_error(*syntax_error(
                'specific_spec.atom_invalid_bonds_num', atom: 'ct', spec: 'bridge'))
          end

          it 'invalid valence too' do
            expect { matcher.match('bridge(ct: *, ct: *, ct: *)') }.
              to raise_error(*syntax_error(
                'specific_spec.atom_invalid_bonds_num', atom: 'ct', spec: 'bridge'))
          end

          it 'twise incoherent' do
            expect { matcher.match('bridge(ct: i, ct: i)') }.
              to raise_error(*syntax_error(
                'specific_spec.atom_already_has_state', state: 'i'))
          end

          it 'twise unfixed' do
            expect { matcher.match('methyl_on_bridge(cm: u, cm: u)') }.
              to raise_error(*syntax_error(
                'specific_spec.atom_already_has_state', state: 'u'))
          end

          describe 'wrong value' do
            before(:each) do
              Tools::Chest.store(h)
              Tools::Chest.store(o)
            end

            it 'invalid keyname' do
              expect { matcher.match('bridge(ct: w)') }.
                to raise_error(*syntax_error(
                  'specific_spec.wrong_specification', atom: 'ct'))
            end

            it 'cannot use not monovalent atom' do
              expect { matcher.match('bridge(ct: O)') }.
                to raise_error(*syntax_error(
                  'specific_spec.wrong_specification', atom: 'ct'))
            end

            it 'cannot be hydride' do
              expect { matcher.match('bridge(ct: **, ct: H)') }.
                to raise_error(*syntax_error(
                  'specific_spec.atom_invalid_bonds_num', atom: 'ct', spec: 'bridge'))
            end
          end
        end
      end
    end

  end
end
