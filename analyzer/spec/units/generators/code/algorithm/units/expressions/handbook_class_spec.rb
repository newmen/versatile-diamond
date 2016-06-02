require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe HandbookClass, type: :algorithm do
          include_context :unique_reactant_context

          subject { described_class[] }
          let(:dict) { VarsDictionary.new }
          let(:var) { dict.make_atom_s(cb, next_name: false) }

          describe '#insert_amorph_atom' do
            let(:code) { 'Handbook::amorph().insert(atom)' }
            it { expect(subject.insert_amorph_atom(var).code).to eq(code) }
          end

          describe '#erase_amorph_atom' do
            let(:code) { 'Handbook::amorph().erase(atom)' }
            it { expect(subject.erase_amorph_atom(var).code).to eq(code) }
          end

          describe '#mark_removing_atom' do
            let(:code) { 'Handbook::scavenger().markAtom(atom)' }
            it { expect(subject.mark_removing_atom(var).code).to eq(code) }
          end
        end

      end
    end
  end
end
