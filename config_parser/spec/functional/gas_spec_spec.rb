require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe GasSpec, type: :interpreter do
      let(:concept) { Concepts::GasSpec.new(:gas_spec) }
      let(:spec) { Interpreter::GasSpec.new(concept) }

      def make_nitrogen
        gas.interpret('spec nitrogen')
        gas.interpret('  atoms n1: N, n2: N')
        gas.interpret('  tbond :n1, :n2')
      end

      before(:each) do
        elements.interpret('atom N, valence: 3')
      end

      describe "#atoms" do
        describe "atoms line with ref to another spec becomes to adsorbing" do
          before(:each) do
            make_nitrogen
            spec.interpret('atoms n: nitrogen(:n1)')
          end

          it { concept.external_bonds_for(concept.atom(:n)).should == 0 }
          it { concept.atom(:n1).should be_nil }
          it { concept.atom(:n2).should be_nil }
        end

        describe "undefined atoms" do
          it { expect { spec.interpret('atoms x: X') }.
            to raise_error keyname_error(:undefined, :atom, :X) }

          it { expect { spec.interpret('atoms n: nitrogen(:n1)') }.
            to raise_error keyname_error(:undefined, :spec, :nitrogen) }
        end
      end

      describe "#aliases" do
        describe "nitrogen" do
          before(:each) do
            make_nitrogen
            spec.interpret('aliases ng: nitrogen')
            spec.interpret('atoms nf: ng(:n1), ns: ng(:n2)')
          end

          it { concept.external_bonds_for(concept.atom(:nf)).should == 0 }
          it { concept.external_bonds_for(concept.atom(:ns)).should == 0 }
          it { concept.size.should == 2 }
        end
      end

      describe "bonds" do
        before(:each) { spec.interpret('atoms n1: N, n2: N') }

        describe "#bond" do
          before(:each) { spec.interpret('bond :n1, :n2') }
          # TODO: check the bond existance too
          it { concept.external_bonds_for(concept.atom(:n1)).should == 2 }
          it { concept.external_bonds_for(concept.atom(:n2)).should == 2 }
        end

        describe "#dbond" do
          before(:each) { spec.interpret('dbond :n1, :n2') }
          # TODO: check the bond existance too
          it { concept.external_bonds_for(concept.atom(:n1)).should == 1 }
          it { concept.external_bonds_for(concept.atom(:n2)).should == 1 }
        end

        describe "#tbond" do
          before(:each) { spec.interpret('tbond :n1, :n2') }
          it { concept.external_bonds_for(concept.atom(:n1)).should == 0 }
          it { concept.external_bonds_for(concept.atom(:n2)).should == 0 }
          # TODO: check the bond existance too
        end
        describe "wrong syntax" do
          let(:wrong_bond) { syntax_error('gas_spec.wrong_bond') }
          it { expect { spec.interpret('bond :n1, :n2, face: 100') }.
            to raise_error wrong_bond }

          it { expect { spec.interpret('bond :n1, :n2, dir: :front') }.
            to raise_error wrong_bond }
        end
      end

      describe "#simple_atom" do
        it { expect { spec.interpret('atoms n1: N, n2: N%nh4') }.
          to raise_error syntax_error(
            'matcher.undefined_used_atom', name: 'N%nh4') }
      end
    end

  end
end
