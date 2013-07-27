require 'spec_helper'

module VersatileDiamond
  module Tools

    describe Chest do
      class Concept < Concepts::Base; end
      before(:each) { Chest.reset }

      let(:concept) { Concept.new(:some) }
      let(:key_name_err) { Chest::KeyNameError }

      describe "#store" do
        it { (Chest.store(concept)).should == Chest }

        let(:concept_dup) { Concept.new(:some) }
        it "duplication of concept" do
          Chest.store(concept)
          -> { Chest.store(concept_dup) }.should raise_error key_name_err
        end

        let(:another) { Concept.new(:another) }
        it "another concept" do
          Chest.store(concept)
          -> { Chest.store(another) }.should_not raise_error key_name_err
        end
      end

      describe "#method_missing" do
        it "store and get concept" do
          Chest.store(concept)
          Chest.concept(:some).should == concept
        end

        it "wrong key of concept" do
          -> { Chest.wrong(:not_important) }.should raise_error key_name_err
        end

        it "wrong name of concept" do
          Chest.store(concept)
          -> { Chest.concept(:wrong) }.should raise_error key_name_err
        end
      end

      describe "#spec" do
        it "gas spec" do
          hello_spec = Concepts::GasSpec.new('hello')
          Chest.store(hello_spec)
          Chest.spec(:hello).should == hello_spec
        end
      end
    end

  end
end
