require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe NameRemember do
          subject { described_class.new }

          describe '#checkpoint! && #rollback!' do
            let(:object) { Object.new }
            let(:array) { [Object.new, Object.new] }
            let(:other) { [1, 2, 3, 5, 8] }
            let(:temp) { :temp }

            it 'expect names' do
              subject.assign!(object, 'name')
              subject.assign_next!(array, 'arr')
              subject.checkpoint! # 1
              subject.reassign!(object, 'other_name')
              subject.assign_next!([4, 2, 1], 'arr')
              subject.assign!(temp, 'temp')
              subject.rollback! # <- 1
              subject.assign_next!(other, 'arr')
              expect(subject.name_of(object)).to eq('name')
              expect(subject.name_of(array)).to eq('arrs1')
              expect(subject.name_of(other)).to eq('arrs2')
              expect(subject.name_of(temp)).to be_nil
              subject.checkpoint! # 2
              subject.reassign!(other, 'lalas')
              expect(subject.name_of(other)).to eq('lalas')
              subject.rollback! # <- 2
              expect(subject.name_of(other)).to eq('arrs2')
              subject.rollback! # <- 2
              expect(subject.name_of(other)).to eq('arrs2')
              subject.rollback!(forget: true) # <- 2
              expect(subject.name_of(other)).to eq('arrs2')
              subject.rollback!(forget: true) # <- 1
              expect(subject.name_of(other)).to be_nil
              expect(subject.name_of(object)).to eq('name')
              expect(subject.name_of(array)).to eq('arrs1')
              subject.rollback!(forget: true) # <- 0
              expect(subject.name_of(object)).to be_nil
              expect(subject.name_of(array)).to be_nil
              subject.rollback! # <- 0
              subject.rollback!(forget: true) # no any error
            end
          end

          describe '#assign!' do
            describe 'no raise error' do
              it { expect { subject.assign!('value', 'var') }.not_to raise_error }
              it { expect { subject.assign!(['value'], 'var') }.not_to raise_error }
            end

            describe 'get the name' do
              it { expect(subject.assign!(:yo, 'nm')).to eq('nm') }
            end

            describe 'duplicate variable' do
              shared_examples_for :check_var_duplicate do
                before { subject.assign!(vars, 'var') }
                it { expect { subject.assign!(vars, 'other') }.to raise_error }
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
                before { subject.assign!(var1, 'var') }
                it { expect { subject.assign!(var2, 'var') }.to raise_error }
              end

              ['a', ['b']].product(['c', ['d']]).each do |var1, var2|
                it_behaves_like :check_name_duplicate do
                  let(:var1) { var1 }
                  let(:var2) { var2 }
                end
              end
            end
          end

          describe '#assign_next!' do
            describe 'with number one' do
              let(:var) { 'value' }
              it { expect(subject.assign_next!(var, 'var')).to eq('var1') }
            end

            describe 'remember index and get next' do
              let(:var) { 'value' }
              before do
                subject.assign_next!(var, 'var')
                subject.erase(var)
                subject.assign_next!(var, 'var')
              end
              it { expect(subject.name_of(var)).to eq('var2') }
            end

            describe 'with number two' do
              let(:var1) { 'value' }
              let(:var2) { 'other' }
              before do
                subject.assign_next!(var1, 'var')
                subject.assign_next!(var2, 'var')
              end
              it { expect(subject.name_of(var2)).to eq('var2') }
            end

            describe 'collection' do
              let(:vars) { [1, 2] }
              before { subject.assign_next!(vars, 'var') }
              it { expect(subject.name_of(vars)).to eq('vars1') }
            end

            describe 'duplicate variable' do
              let(:var) { 'value' }
              before { subject.assign_next!(var, 'var') }

              it 'with same var name' do
                expect { subject.assign_next!(var, 'var') }.to raise_error
              end

              it 'with another var name' do
                expect { subject.assign_next!(var, 'other') }.to raise_error
              end
            end
          end

          describe '#reassign!' do
            shared_examples_for :check_reassign do
              before do
                subject.assign!(var1, 'var')
                subject.reassign!(var2, 'var')
              end

              it { expect(subject.name_of(1)).to be_nil }
              it { expect(subject.name_of(2)).to eq('var') }
              it { expect(subject.reassign!(var1, 'meow')).to eq('meow') }
            end

            [1, [1]].product([2, [2]]) do |var1, var2|
              it_behaves_like :check_reassign do
                let(:var1) { var1 }
                let(:var2) { var2 }
              end
            end
          end

          describe '#reassign_next!' do
            shared_examples_for :check_reassign_next do
              before do
                subject.assign!(var1, 'var')
                subject.reassign_next!(var2, 'var')
              end

              it { expect(subject.name_of(1)).to eq('var') }
              it { expect(subject.name_of(2)).to eq('var1') }
              it { expect(subject.reassign_next!(var1, 'meow')).to eq('meow1') }

              describe 'many times' do
                before { subject.reassign_next!(var1, 'meow') }
                it { expect(subject.reassign_next!(var1, 'meow')).to eq('meow2') }
              end
            end

            [1, [1]].product([2, [2]]) do |var1, var2|
              it_behaves_like :check_reassign_next do
                let(:var1) { var1 }
                let(:var2) { var2 }
              end
            end
          end

          describe '#prev_names_of' do
            it { expect(subject.prev_names_of(123)).to be_nil }

            describe 'with name' do
              let(:xx) { Object.new }
              let(:yy) { Object.new }

              before do
                subject.assign!(xx, 'xx')
                subject.assign!(yy, 'yy')
              end

              it { expect(subject.prev_names_of(xx)).to be_nil }

              describe 'rename' do
                before { subject.reassign!(xx, 'yy') }
                it { expect(subject.prev_names_of(xx)).to eq(['xx']) }
                it { expect(subject.prev_names_of(yy)).to eq(['yy']) }

                describe 'one more time' do
                  before { subject.reassign!(xx, 'zz') }
                  it { expect(subject.prev_names_of(xx)).to eq(['xx', 'yy']) }
                  it { expect(subject.prev_names_of(yy)).to eq(['yy']) }

                  describe 'erase' do
                    before { subject.erase(xx) }
                    it { expect(subject.prev_names_of(xx)).to eq(['xx', 'yy', 'zz']) }
                  end
                end
              end
            end
          end

          describe '#name_of' do
            describe 'argument is object' do
              describe 'single variable' do
                let(:var) { 123 }
                before { subject.assign!(var, 'var') }
                it { expect(subject.name_of(var)).to eq('var') }
              end

              describe 'many variables' do
                let(:vars) { [1, 2, 3] }
                before { subject.assign!(vars, 'var') }
                it { expect(subject.name_of(2)).to eq('vars[1]') }
              end

              it 'undefined variable' do
                expect(subject.name_of('wrong')).to be_nil
              end
            end

            describe 'argument is array' do
              describe 'all is correct' do
                let(:vars) { ['a', 'b', 'c'] }
                before { subject.assign!(vars, 'var') }
                it { expect(subject.name_of(vars)).to eq('vars') }
              end

              describe 'incorrect vars set' do
                let(:vars) { ['a', 'b'] }
                let(:excess_var) { 'c' }

                shared_examples_for :check_error_raising do
                  before { subject.assign!(vars, 'var') }
                  it { expect { subject.name_of(vars + [excess_var]) }.to raise_error }
                end

                describe 'excess vars' do
                  before { subject.assign!(excess_var, 'other') }
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

          describe '#defined_vars' do
            it { expect(subject.defined_vars).to be_empty }

            describe 'not empty' do
              let(:var) { Object.new }
              before { subject.assign!(var, 'x') }
              it { expect(subject.defined_vars).to eq([var]) }

              describe 'many' do
                let(:other) { :other }
                before { subject.assign!(other, 'foo') }
                it { expect(subject.defined_vars).to match_array([var, other]) }

                describe 'rename' do
                  before { subject.reassign!(var, 'hi') }
                  it { expect(subject.defined_vars).to match_array([var, other]) }
                end

                describe 'erase' do
                  before { subject.erase(var) }
                  it { expect(subject.defined_vars).to eq([other]) }
                end
              end
            end
          end

          describe '#erase' do
            shared_examples_for :check_erase do
              let(:other) { :other }
              before do
                subject.assign!(other, 'other')
                subject.assign!(vars, 'var')
              end

              let(:result) { subject.erase(vars) }
              let(:many) { false }
              it { expect(result).to eq(many ? ["vars[0]", "vars[1]"] : 'var') }

              describe 'check next time' do
                before { result }
                it { expect(subject.name_of(vars)).to be_nil }
                it { expect(subject.name_of(other)).not_to be_nil }
              end
            end

            it_behaves_like :check_erase do
              let(:vars) { 'value' }
            end

            it_behaves_like :check_erase do
              let(:vars) { ['value'] }
            end

            it_behaves_like :check_erase do
              let(:many) { true }
              let(:vars) { [1, 2] }
            end
          end

          describe '#full_array?' do
            describe 'single variable' do
              let(:var) { :var }
              before { subject.assign!(var, 'var') }
              it { expect(subject.full_array?([var])).to be_falsey }
            end

            describe 'many variables' do
              let(:vars) { [1, 2] }
              before { subject.assign!(vars, 'var') }

              describe 'same array varaible name' do
                it { expect(subject.full_array?(vars)).to be_truthy }
              end

              describe 'different array varaible name' do
                let(:others) { [3, 4] }
                let(:array) { [vars.first, others.first] }
                before { subject.assign!(others, 'other') }
                it { expect(subject.full_array?(array)).to be_falsey }
              end

              describe 'one var is not an array' do
                let(:other) { :other }
                let(:array) { [vars.first, other] }
                before { subject.assign!(other, 'other') }
                it { expect(subject.full_array?(array)).to be_falsey }
              end
            end

            describe 'too many items of array' do
              let(:vars) { [1, 2] }
              let(:all) { vars + [3, 4] }
              before { subject.assign!(all, 'var') }
              it { expect(subject.full_array?(vars)).to be_falsey }
            end
          end
        end

      end
    end
  end
end
