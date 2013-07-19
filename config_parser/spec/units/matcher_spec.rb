require 'spec_helper'

module VersatileDiamond

  describe Matcher do
    describe "matching active bond" do
      let(:method) { Matcher.method(:active_bond) }

      it "when passed the star" do
        method['*'].should == '*'
      end

      it "when passed something else" do
        method['H'].should be_nil
        method['hello'].should be_nil
      end
    end

    describe "matching typical atom" do
      let(:method) { Matcher.method(:atom) }

      it "when passed the atom name" do
        method['H'].should == 'H'
        method['Cu'].should == 'Cu'
        method['S6'].should == 'S6'
        method['Uut2'].should == 'Uut2'
      end

      it "when passed something else" do
        method['carbon'].should be_nil
        method['H2O'].should be_nil
      end
    end

    describe "matching specified atom" do
      let(:method) { Matcher.method(:specified_atom) }

      it "when passed the atom name with lattice through percent" do
        method['C%d'].should == ['C', 'd']
        method['Cu%sq'].should == ['Cu', 'sq']
        method['S6%hex'].should == ['S6', 'hex']
      end

      it "when passed something else" do
        method['C'].should be_nil
        method['S%'].should be_nil
        method['%d'].should be_nil
        method['carbon%diamond'].should be_nil
        method['C %d'].should be_nil
        method['C% d'].should be_nil
        method['C % d'].should be_nil
      end
    end

    describe "matching used atom" do
      let(:method) { Matcher.method(:used_atom) }

      it "when passed the spec name with atom keyname in brackets" do
        method['bridge(:ct)'].should == ['bridge', 'ct']
        method['dimer( :cr )'].should == ['dimer', 'cr']
        method['benzol(:c_3 )'].should == ['benzol', 'c_3']
      end

      it "when passed something else" do
        method['BRIDGE(:ct)'].should be_nil
        method['bridge (:ct)'].should be_nil
        method['bridge(ct)'].should be_nil
        method['bridge[:ct]'].should be_nil
        method['bridge(:ct'].should be_nil
        method['bridge()'].should be_nil
        method['bridge(:)'].should be_nil
      end
    end

    describe "matching specified spec" do
      let(:method) { Matcher.method(:specified_spec) }

      it "when passed the spec name with options in brackets" do
        method['bridge(ct: *)'].should == ['bridge', 'ct: *']
        method['dimer( cr: i )'].should == ['dimer', 'cr: i']
        method['dm(cr: i, cl: u)'].should == ['dm', 'cr: i, cl: u']
        method['methyl_on_brdg'].should == ['methyl_on_brdg', nil]
      end

      it "when passed something else" do
        method['BRIDGE(ct: *)'].should be_nil
        method['bridge (ct: *)'].should be_nil
        method['bridge(ct: *'].should be_nil
        method['bridge[ct: *]'].should be_nil
        method['bridge()'].should be_nil
      end
    end

    describe "matching equation" do
      let(:method) { Matcher.method(:equation) }

      it "when passed ubiquitous equation" do
        method['H + hydrogen(h: *) = * + hydrogen'].
          should == [['H', 'hydrogen(h: *)'], ['*', 'hydrogen']]

        method['*+hydrogen(h: *)  =   H'].
          should == [['*', 'hydrogen(h: *)'], ['H']]
      end

      it "when passed typical equation" do
        method['bridge(cr: *) + hydrogen(h: *) = bridge'].
          should == [['bridge(cr: *)', 'hydrogen(h: *)'], ['bridge']]

        method['one(ct: * )+two( ct: *)  =  dimer'].
          should == [['one(ct: * )', 'two( ct: *)'], ['dimer']]
      end

      it "when passed something else" do
        method['one(ct: *) + two( ct: *) => dimer'].should be_nil
        method['one(ct: *) + two( ct: *) -> dimer'].should be_nil
        method['one(ct: *) + = dimer'].should be_nil
        method['= dimer'].should be_nil
      end
    end
  end

end
