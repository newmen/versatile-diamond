require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Environment, type: :interpreter do
      let(:environment) { Environment.new(dimers_row) }

      describe '#targets' do
        before { environment.interpret('targets :one_atom, :two_atom') }
        it { expect(dimers_row.is_target?(:one_atom)).to be_true }
        it { expect(dimers_row.is_target?(:two_atom)).to be_true }
        it { expect(dimers_row.is_target?(:wrong)).to be_false }
      end

      describe '#aliases' do
        before(:each) { interpret_basis }
        it { expect { environment.interpret('aliases f: dimer, s: dimer') }.
          not_to raise_error }

        it { expect { environment.interpret('aliases one: wrong') }.
          to raise_error *keyname_error(:undefined, :spec, :wrong) }

        describe 'aliases use specific specs' do
          before do
            environment.interpret('targets :o')
            environment.interpret('aliases f: dimer')
            environment.interpret('where :some, "description"')
            environment.interpret(
              '  position o, f(:cr), face: 100, dir: :front')
          end
          let(:where) { Tools::Chest.where(:dimers_row, :some) }
          it { expect(where.specs.map(&:name)).to match_array([:dimer]) }
        end
      end

      describe '#where' do
        before(:each) do
          environment.interpret('where :end_row, "at end of dimers row"')
        end

        it { expect(Tools::Chest.where(:dimers_row, :end_row)).
          to be_a(Concepts::Where) }

        it { expect { environment.interpret('where :end_row, "some desc"') }.
          to raise_error *keyname_error(:duplication, :where, :end_row) }
      end
    end

  end
end
