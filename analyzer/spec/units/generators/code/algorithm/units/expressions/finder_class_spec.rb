require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe FinderClass, type: :algorithm do
          include_context :unique_reactant_context

          subject { described_class[] }
          let(:dict) { VarsDictionary.new }

          describe '#find_all' do
            describe 'one atom' do
              let(:var) { dict.make_atom_s(cm, next_name: false) }
              let(:code) { 'Finder::findAll(&amorph, 1)' }
              it { expect(subject.find_all(var).code).to eq(code) }
            end

            describe 'many atoms' do
              let(:arr) { dict.make_atom_s([cm, cb], next_name: false) }
              let(:code) { 'Finder::findAll(atoms, 2)' }
              it { expect(subject.find_all(arr).code).to eq(code) }
            end
          end
        end

      end
    end
  end
end
