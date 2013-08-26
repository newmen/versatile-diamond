require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Spec, type: :interpreter do
      let(:concept) { Concepts::Spec.new(:spec_name) }
      let(:spec) { Interpreter::Spec.new(concept) }

      before(:each) do
        elements.interpret('atom N, valence: 3')
      end

      def make_nitrogen
        gas.interpret('spec nitrogen')
        gas.interpret('  atoms n1: N, n2: N')
        gas.interpret('  tbond :n1, :n2')
      end

      describe "#atoms" do
        it "atoms line becomes to concept as instances of Atom" do
          spec.interpret('atoms n: N')
          concept.atom(:n).name.should == :N
        end

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
            to raise_error syntax_error }

          it { expect { spec.interpret('atoms n: nitrogen(:n1)') }.
            to raise_error syntax_error }
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

        describe "undefined spec" do
          it { expect { spec.interpret('aliases ng: nitrogen') }.
            to raise_error syntax_error }
        end
      end

      describe "bonds" do
        before(:each) do
          spec.interpret('atoms n1: N, n2: N')
        end

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
      end
    end

  end
end
