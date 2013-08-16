module VersatileDiamond
  module Interpreter
    module Support

      module ReactionRefinements
        shared_examples_for "reaction refinemenets" do
          subject do
            described_class.new(methyl_desorption, md_names_to_specs)
          end

          shared_examples_for "check state" do
            it { expect { subject.interpret("#{state} #{name}(:#{keyname})") }.
              not_to raise_error }

            it { expect { subject.interpret("#{state} wrong(:c)") }.
              to raise_error syntax_error }
            it { expect { subject.interpret("#{state} mob(:wrong)") }.
              to raise_error syntax_error }

            describe "wrong names to specs" do
              subject do
                described_class.new(dimer_formation, {
                  source: [[:b, activated_bridge], [:b, df_source.last]],
                  products: [[:d, dimer]]
                })
              end

              it { expect { subject.interpret("#{state} b(:ct)") }.
                to raise_error syntax_error }
            end
          end

          describe "#incoherent" do
            it_behaves_like "check state" do
              let(:state) { :incoherent }
              let(:name) { :mob }
              let(:atom) { :methyl_on_bridge }
              let(:keyname) { :cb }
            end

            describe "property is realy state" do
              before { subject.interpret("incoherent b(:ct)") }
              it { activated_cd.incoherent?.should be_true }
            end
          end

          describe "#unfixed" do
            it_behaves_like "check state" do
              let(:state) { :unfixed }
              let(:name) { :mob }
              let(:atom) { :methyl_on_bridge }
              let(:keyname) { :cm }
            end

            describe "property is realy state" do
              subject do
                described_class.new(hydrogen_migration, hm_names_to_specs)
              end

              before { subject.interpret("unfixed mod(:cm)") }
              it { activated_c.unfixed?.should be_true }
            end
          end

          describe "#position" do
            subject { described_class.new(dimer_formation, df_names_to_specs) }

            describe "default value" do
              it { dimer_formation.positions.should be_empty }
            end

            describe "all right" do
              before(:each) do
                subject.interpret('position b1(:ct), b2(:ct), face: 100, dir: :front')
              end

              it { dimer_formation.positions.should_not be_empty }

              describe "duplication" do
                it { expect { subject.interpret('position b2(:ct), b1(:ct), face: 100, dir: :cross') }.
                  to raise_error syntax_error }
              end
            end

            describe "incomplete" do
              it { expect { subject.interpret('position b2(:ct), b1(:ct), face: 100') }.
                to raise_error syntax_error }
            end
          end
        end
      end

    end
  end
end
