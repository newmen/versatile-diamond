require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Spec do
      let(:concept) { Concepts::Spec.new(:spec_name) }
      let(:spec) { Interpreter::Spec.new(concept) }
      let(:elements) { Elements.new }
      let(:gas) { Gas.new }
      let(:keyname_error) { Tools::Chest::KeyNameError }

      before(:each) do
        elements.interpret('atom N, valence: 3')
      end

      def make_nitrogen
        gas = Gas.new
        gas.interpret('spec nitrogen')
        gas.interpret('  atoms n1: N, n2: N')
        gas.interpret('  tbond :n1, :n2')
      end

      describe "#atoms" do
        it "atoms line becomes to concept as instances of Atom" do
          spec.interpret('atoms n: N')
          concept.atom(:n).name.should == :N
        end

        it "atoms line with ref to another spec becomes to adsorbing" do
          make_nitrogen
          spec.interpret('atoms n: nitrogen(:n1)')
          concept.external_bonds_for(concept.atom(:n)).should == 0
          concept.atom(:n1).should be_nil
          concept.atom(:n2).should be_nil
        end

        it { -> { spec.interpret('atoms x: X') }.
          should raise_error keyname_error }

        it { -> { spec.interpret('atoms n: nitrogen(:n1)') }.
          should raise_error keyname_error }
      end

      describe "#aliases" do
        it "aliases adsrobs to concept" do
          make_nitrogen
          spec.interpret('aliases ng: nitrogen')
          spec.interpret('atoms nf: ng(:n1), ns: ng(:n2)')
          concept.external_bonds_for(concept.atom(:nf)).should == 0
          concept.external_bonds_for(concept.atom(:ns)).should == 0
          concept.duplicate_atoms_with_keynames.size.should == 2
        end

        it { -> { spec.interpret('aliases ng: nitrogen') }.
          should raise_error keyname_error }
      end

      describe "bonds" do
        before(:each) do
          spec.interpret('atoms n1: N, n2: N')
        end

        describe "#bond" do
          it "setup changes value of #extended_bonds_for method" do
            spec.interpret('bond :n1, :n2')
            # TODO: check the bond existance
            concept.external_bonds_for(concept.atom(:n1)).should == 2
            concept.external_bonds_for(concept.atom(:n2)).should == 2
          end
        end

        describe "#dbond" do
          it "twise setup changes value of #extended_bonds_for method" do
            spec.interpret('dbond :n1, :n2')
            # TODO: check the bond existance too
            concept.external_bonds_for(concept.atom(:n1)).should == 1
            concept.external_bonds_for(concept.atom(:n2)).should == 1
          end
        end

        describe "#tbond" do
          it "triple setup changes value of #extended_bonds_for method" do
            spec.interpret('tbond :n1, :n2')
            # TODO: check the bond existance too
            concept.external_bonds_for(concept.atom(:n1)).should == 0
            concept.external_bonds_for(concept.atom(:n2)).should == 0
          end
        end
      end
    end

  end
end
