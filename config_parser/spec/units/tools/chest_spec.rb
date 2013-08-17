require 'spec_helper'

module VersatileDiamond
  module Tools

    describe Chest do
      class Concept < Concepts::Named; end

      let(:concept) { Concept.new(:some) }
      let(:o_dups) { [Concept.new(:some)] }
      let(:o_another) { [Concept.new(:another)] }
      let(:m_dups) { [Concept.new(:first), Concept.new(:some)] }
      let(:m_another) { [Concept.new(:first), Concept.new(:second)] }

      let(:keyname_error) { Chest::KeyNameError }

      describe "#store" do
        it { (Chest.store(concept)).should == Chest }

        shared_examples_for "check duplication" do
          describe "duplication" do
            before { Chest.store(*dups) }
            it { expect { Chest.store(*dups.map(&:dup)) }.
              to raise_error keyname_error }
          end

          describe "another concept" do
            before { Chest.store(*dups) }
            it { expect { Chest.store(*another.map(&:dup)) }.
              to_not raise_error }
          end
        end

        it_behaves_like "check duplication" do
          let(:dups) { o_dups }
          let(:another) { o_another }
        end

        it_behaves_like "check duplication" do
          let(:dups) { m_dups }
          let(:another) { m_another }
        end
      end

      describe "#method_missing" do
        shared_examples_for "store and get concept" do
          before { Chest.store(*concepts) }
          it { Chest.concept(*concepts.map(&:name)).should == concepts.last }
        end

        it_behaves_like "store and get concept" do
          let(:concepts) { o_dups }
        end

        it_behaves_like "store and get concept" do
          let(:concepts) { m_dups }
        end

        it "wrong key of concept" do
          expect { Chest.wrong(:not_important) }.to raise_error keyname_error
        end

        it "wrong name of concept" do
          Chest.store(concept)
          expect { Chest.concept(:wrong) }.to raise_error keyname_error
        end
      end

      # describe "#spec" do
      #   describe "gas spec" do
      #     before { Chest.store(methane_base) }
      #     it { Chest.spec(:methane).should == methane_base }
      #   end

      #   describe "surface spec" do
      #     before { Chest.store(bridge_base) }
      #     it { Chest.spec(:bridge).should == bridge_base }
      #   end
      # end
    end

  end
end
