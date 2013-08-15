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
                described_class.new(methyl_desorption, hm_names_to_specs)
              end

              before { subject.interpret("unfixed mod(:cm)") }
              it { activated_c.unfixed?.should be_true }
            end
          end
        end
      end

    end
  end
end
