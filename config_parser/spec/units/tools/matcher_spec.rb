require 'spec_helper'

module VersatileDiamond
  module Tools

    describe Matcher do
      describe "#active_bond" do
        let(:method) { Matcher.method(:active_bond) }

        it { method['*'].should == '*' }

        describe "wrong" do
          it { method['H'].should be_nil }
          it { method['hello'].should be_nil }
        end
      end

      describe "#atom" do
        let(:method) { Matcher.method(:atom) }

        it { method['H'].should == 'H' }
        it { method['Cu'].should == 'Cu' }
        it { method['S6'].should == 'S6' }
        it { method['Uut2'].should == 'Uut2' }

        describe "wrong" do
          it { method['carbon'].should be_nil }
          it { method['H2O'].should be_nil }
        end
      end

      describe "#specified_atom" do
        let(:method) { Matcher.method(:specified_atom) }

        it { method['C%d'].should == ['C', 'd'] }
        it { method['Cu%sq'].should == ['Cu', 'sq'] }
        it { method['S6%hex'].should == ['S6', 'hex'] }

        describe "wrong" do
          it { method['C'].should be_nil }
          it { method['S%'].should be_nil }
          it { method['%d'].should be_nil }
          it { method['carbon%diamond'].should be_nil }
          it { method['C %d'].should be_nil }
          it { method['C% d'].should be_nil }
          it { method['C % d'].should be_nil }
        end
      end

      describe "#used_atom" do
        let(:method) { Matcher.method(:used_atom) }

        it { method['bridge(:ct)'].should == ['bridge', 'ct'] }
        it { method['dimer( :cr )'].should == ['dimer', 'cr'] }
        it { method['benzol(:c_3 )'].should == ['benzol', 'c_3'] }

        describe "wrong" do
          it { method['BRIDGE(:ct)'].should be_nil }
          it { method['bridge (:ct)'].should be_nil }
          it { method['bridge(ct)'].should be_nil }
          it { method['bridge[:ct]'].should be_nil }
          it { method['bridge(:ct'].should be_nil }
          it { method['bridge()'].should be_nil }
          it { method['bridge(:)'].should be_nil }
        end
      end

      describe "#specified_spec" do
        let(:method) { Matcher.method(:specified_spec) }

        it { method['bridge(ct: *)'].should == ['bridge', 'ct: *'] }
        it { method['dimer( cr: i )'].should == ['dimer', 'cr: i'] }
        it { method['dm(cr: i, cl: u)'].should == ['dm', 'cr: i, cl: u'] }
        it { method['methyl_on_brdg'].should == ['methyl_on_brdg', nil] }

        describe "wrong" do
          it { method['BRIDGE(ct: *)'].should be_nil }
          it { method['bridge (ct: *)'].should be_nil }
          it { method['bridge(ct: *'].should be_nil }
          it { method['bridge[ct: *]'].should be_nil }
          it { method['bridge()'].should be_nil }
        end
      end

      describe "#equation" do
        let(:method) { Matcher.method(:equation) }

        describe "ubiquitous" do
          it { method['H + hydrogen(h: *) = * + hydrogen'].
              should == [['H', 'hydrogen(h: *)'], ['*', 'hydrogen']] }
          it { method['*+hydrogen(h: *)  =   H'].
              should == [['*', 'hydrogen(h: *)'], ['H']] }
        end

        describe "typical" do
          it { method['bridge(cr: *) + hydrogen(h: *) = bridge'].
              should == [['bridge(cr: *)', 'hydrogen(h: *)'], ['bridge']] }
          it { method['one(ct: * )+two( ct: *)  =  dimer'].
              should == [['one(ct: * )', 'two( ct: *)'], ['dimer']] }
        end

        describe "wrong" do
          it { method['one(ct: *) + two( ct: *) => dimer'].should be_nil }
          it { method['one(ct: *) + two( ct: *) -> dimer'].should be_nil }
          it { method['one(ct: *) + two( ct: = dimer'].should be_nil }
          it { method['one(ct: *) + = dimer'].should be_nil }
          it { method['= dimer'].should be_nil }
        end
      end
    end

  end
end
