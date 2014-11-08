require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe NameRemember do
          subject { described_class.new }

          describe '#assign' do
            describe 'no raise error' do
              it { expect { subject.assign('var', 'value') }.not_to raise_error }
              it { expect { subject.assign('var', ['value']) }.not_to raise_error }
            end

            describe 'duplicate variable' do
              shared_examples_for :check_var_duplicate do
                before { subject.assign('var', vars) }
                it { expect { subject.assign('other', vars) }.to raise_error }
              end

              it_behaves_like :check_var_duplicate do
                let(:vars) { 'value' }
              end

              it_behaves_like :check_var_duplicate do
                let(:vars) { ['value'] }
              end
            end

            describe 'duplicate name' do
              shared_examples_for :check_name_duplicate do
                before { subject.assign('var', var1) }
                it { expect { subject.assign('var', var2) }.to raise_error }
              end

              ['a', ['b']].product(['c', ['d']]).each do |var1, var2|
                it_behaves_like :check_name_duplicate do
                  let(:var1) { var1 }
                  let(:var2) { var2 }
                end
              end
            end
          end

          describe '#assign_next' do
            describe 'with number one' do
              let(:var) { 'value' }
              before { subject.assign_next('var', var) }
              it { expect(subject.name_of(var)).to eq('var1') }
            end

            describe 'remember index and get next' do
              let(:var) { 'value' }
              before do
                subject.assign_next('var', var)
                subject.erase(var)
                subject.assign_next('var', var)
              end
              it { expect(subject.name_of(var)).to eq('var2') }
            end

            describe 'with number two' do
              let(:var1) { 'value' }
              let(:var2) { 'other' }
              before do
                subject.assign_next('var', var1)
                subject.assign_next('var', var2)
              end
              it { expect(subject.name_of(var2)).to eq('var2') }
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
            shared_examples_for :check_reassign do
              before do
                subject.assign('var', var1)
                subject.reassign('var', var2)
              end

              it { expect(subject.name_of(1)).to be_nil }
              it { expect(subject.name_of(2)).to eq('var') }
            end

            [1, [1]].product([2, [2]]) do |var1, var2|
              it_behaves_like :check_reassign do
                let(:var1) { var1 }
                let(:var2) { var2 }
              end
            end
          end

          describe '#name_of' do
            describe 'argument is object' do
              describe 'single variable' do
                let(:var) { 123 }
                before { subject.assign('var', var) }
                it { expect(subject.name_of(var)).to eq('var') }
              end

              describe 'many variables' do
                let(:vars) { [1, 2, 3] }
                before { subject.assign('var', vars) }
                it { expect(subject.name_of(2)).to eq('vars[1]') }
              end

              it 'undefined variable' do
                expect(subject.name_of('wrong')).to be_nil
              end
            end

            describe 'argument is array' do
              describe 'all is correct' do
                let(:vars) { ['a', 'b', 'c'] }
                before { subject.assign('var', vars) }
                it { expect(subject.name_of(vars)).to eq('vars') }
              end

              describe 'incorrect vars set' do
                let(:vars) { ['a', 'b'] }
                let(:excess_var) { 'c' }

                shared_examples_for :check_error_raising do
                  before { subject.assign('var', vars) }
                  it { expect { subject.name_of(vars + [excess_var]) }.to raise_error }
                end

                describe 'excess vars' do
                  before { subject.assign('other', excess_var) }
                  it_behaves_like :check_error_raising
                end

                describe 'not all vars is prestented' do
                  it_behaves_like :check_error_raising
                end
              end

              it 'undefined variable' do
                expect(subject.name_of(['not', 'defined', 'array'])).to be_nil
              end
            end
          end

          describe '#erase' do
            shared_examples_for :check_erase do
              let(:other) { :other }
              before do
                subject.assign('other', other)
                subject.assign('var', vars)
                subject.erase(vars)
              end

              it { expect(subject.name_of(vars)).to be_nil }
              it { expect(subject.name_of(other)).not_to be_nil }
            end

            it_behaves_like :check_erase do
              let(:vars) { 'value' }
            end

            it_behaves_like :check_erase do
              let(:vars) { ['value'] }
            end

            it_behaves_like :check_erase do
              let(:vars) { [1, 2] }
            end
          end
        end

      end
    end
  end
end
