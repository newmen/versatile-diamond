require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Namer do
        subject { described_class.new }

        describe '#assign' do
          it 'no raise error' do
            expect { subject.assign('var', ['value']) }.not_to raise_error
          end

          it 'empty variables array' do
            expect { subject.assign('var', []) }.to raise_error
          end

          it 'duplicate variable' do
            var = 'value'
            subject.assign('var', [var])
            expect { subject.assign('other', [var]) }.to raise_error
          end

          it 'duplicate name' do
            subject.assign('var', ['value'])
            expect { subject.assign('var', ['other']) }.to raise_error
          end
        end

        describe '#reassign' do
          before do
            subject.assign('var', [1])
            subject.reassign('var', [2])
          end

          it { expect(subject.get(2)).to eq('var') }
          it 'not available by old value' do
            expect { subject.get(1) }.to raise_error
          end
        end

        describe '#get' do
          describe 'single variable' do
            let(:var) { 123 }
            before { subject.assign('var', [var]) }
            it { expect(subject.get(var)).to eq('var') }
          end

          describe 'many variables' do
            let(:vars) { [1, 2, 3] }
            before { subject.assign('var', vars) }
            it { expect(subject.get(2)).to eq('vars[1]') }
          end

          it 'undefined variable' do
            expect { subject.get('wrong') }.to raise_error
          end
        end

        describe '#array_name_for' do
          before { subject.assign('var', vars) }

          describe 'all is correct' do
            let(:vars) { ['a', 'b', 'c'] }
            it { expect(subject.array_name_for(vars)).to eq('vars') }
          end

          describe 'incorrect vars array' do
            let(:vars) { ['a', 'b'] }
            it 'variable is excess' do
              excess_vars = ['c']
              subject.assign('other', excess_vars)
              expect { subject.array_name_for(vars + excess_vars) }.to raise_error
            end
          end

          describe 'vars with one item' do
            let(:vars) { ['a'] }
            it 'variable is excess' do
              expect { subject.array_name_for(vars) }.to raise_error
            end
          end
        end
      end

    end
  end
end
