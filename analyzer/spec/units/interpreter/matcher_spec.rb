require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Matcher do
      describe '#active_bond' do
        let(:method) { Matcher.method(:active_bond) }

        it { expect(method['*']).to eq('*') }

        describe 'wrong' do
          it { expect(method['H']).to be_nil }
          it { expect(method['hello']).to be_nil }
        end
      end

      describe '#atom' do
        let(:method) { Matcher.method(:atom) }

        it { expect(method['H']).to eq('H') }
        it { expect(method['Cu']).to eq('Cu') }
        it { expect(method['S6']).to eq('S6') }
        it { expect(method['Uut2']).to eq('Uut2') }

        describe 'wrong' do
          it { expect(method['carbon']).to be_nil }
          it { expect(method['H2O']).to be_nil }
        end
      end

      describe '#specified_atom' do
        let(:method) { Matcher.method(:specified_atom) }

        it { expect(method['C%d']).to match_array(['C', 'd']) }
        it { expect(method['Cu%sq']).to match_array(['Cu', 'sq']) }
        it { expect(method['S6%hex']).to match_array(['S6', 'hex']) }

        describe 'wrong' do
          it { expect(method['C']).to be_nil }
          it { expect(method['S%']).to be_nil }
          it { expect(method['%d']).to be_nil }
          it { expect(method['carbon%diamond']).to be_nil }
          it { expect(method['C %d']).to be_nil }
          it { expect(method['C% d']).to be_nil }
          it { expect(method['C % d']).to be_nil }
        end
      end

      describe '#used_atom' do
        let(:method) { Matcher.method(:used_atom) }

        it { expect(method['bridge(:ct)']).to match_array(['bridge', 'ct']) }
        it { expect(method['dimer( :cr )']).to match_array(['dimer', 'cr']) }
        it { expect(method['benzol(:c_3 )']).to match_array(['benzol', 'c_3']) }

        describe 'wrong' do
          it { expect(method['BRIDGE(:ct)']).to be_nil }
          it { expect(method['bridge (:ct)']).to be_nil }
          it { expect(method['bridge(ct)']).to be_nil }
          it { expect(method['bridge[:ct]']).to be_nil }
          it { expect(method['bridge(:ct']).to be_nil }
          it { expect(method['bridge()']).to be_nil }
          it { expect(method['bridge(:)']).to be_nil }
        end
      end

      describe '#specified_spec' do
        let(:method) { Matcher.method(:specified_spec) }

        it { expect(method['bridge(ct: *)']).to match_array(['bridge', 'ct: *']) }
        it { expect(method['dimer( cr: i )']).to match_array(['dimer', 'cr: i']) }
        it { expect(method['dm(cr: i, cl: u)']).to match_array(['dm', 'cr: i, cl: u']) }
        it { expect(method['methyl_on_brdg']).to match_array(['methyl_on_brdg', nil]) }

        describe 'wrong' do
          it { expect(method['BRIDGE(ct: *)']).to be_nil }
          it { expect(method['bridge (ct: *)']).to be_nil }
          it { expect(method['bridge(ct: *']).to be_nil }
          it { expect(method['bridge[ct: *]']).to be_nil }
          it { expect(method['bridge()']).to be_nil }
        end
      end

      describe '#equation' do
        let(:method) { Matcher.method(:equation) }

        describe 'ubiquitous' do
          it { expect(method['H + hydrogen(h: *) = * + hydrogen']).
              to match_array([['H', 'hydrogen(h: *)'], ['*', 'hydrogen']]) }
          it { expect(method['*+hydrogen(h: *)  =   H']).
              to match_array([['*', 'hydrogen(h: *)'], ['H']]) }
        end

        describe 'typical' do
          it { expect(method['bridge(cr: *) + hydrogen(h: *) = bridge']).
              to match_array([['bridge(cr: *)', 'hydrogen(h: *)'], ['bridge']]) }
          it { expect(method['one(ct: * )+two( ct: *)  =  dimer']).
              to match_array([['one(ct: * )', 'two( ct: *)'], ['dimer']]) }
        end

        describe 'wrong' do
          it { expect(method['one(ct: *) + two( ct: *) => dimer']).to be_nil }
          it { expect(method['one(ct: *) + two( ct: *) -> dimer']).to be_nil }
          it { expect(method['one(ct: *) + two( ct: = dimer']).to be_nil }
          it { expect(method['one(ct: *) + = dimer']).to be_nil }
          it { expect(method['= dimer']).to be_nil }
        end
      end
    end

  end
end
