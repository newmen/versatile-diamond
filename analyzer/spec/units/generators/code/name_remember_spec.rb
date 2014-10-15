require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe NameRemember do
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

        describe '#assign_next' do
          describe 'with number one' do
            let(:var) { 'value' }
            before { subject.assign_next('var', var) }
            it { expect(subject.get(var)).to eq('var1') }
          end

          describe 'with number two' do
            let(:var1) { 'value' }
            let(:var2) { 'other' }
            before do
              subject.assign_next('var', var1)
              subject.assign_next('var', var2)
            end
            it { expect(subject.get(var2)).to eq('var2') }
          end

          describe 'duplicate variable' do
            let(:var) { 'value' }
            before { subject.assign_next('var', var) }

            it 'with same var name' do
              expect { subject.assign_next('var', var) }.to raise_error
            end

            it 'with another var name' do
              expect { subject.assign_next('other', var) }.to raise_error
            end
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

        describe '#erase' do
          let(:vars) { [1, 2] }
          let(:other) { :other }
          before do
            subject.assign('other', [other])
            subject.assign('var', vars)
            subject.erase(vars)
          end
          it { expect(subject.assigned?(vars.first)).to be_falsey }
          it { expect(subject.assigned?(vars.last)).to be_falsey }
          it { expect(subject.assigned?(other)).to be_truthy }
        end

        describe '#assigned?' do
          let(:var) { :value }

          describe 'yes' do
            before { subject.assign('var', [var]) }
            it { expect(subject.assigned?(var)).to be_truthy }
          end

          describe 'no' do
            it { expect(subject.assigned?(var)).to be_falsey }
          end
        end
      end

    end
  end
end