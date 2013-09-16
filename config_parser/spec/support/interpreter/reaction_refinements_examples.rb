module VersatileDiamond
  module Interpreter
    module Support

      module ReactionRefinementsExamples
        shared_examples_for "reaction refinemenets" do
          subject do
            described_class.new(hydrogen_migration, hm_names_to_specs)
          end

          shared_examples_for "check state" do
            it { expect { subject.interpret("#{state} #{name}(:#{keyname})") }.
              not_to raise_error }

            it { expect { subject.interpret("#{state} wrong(:c)") }.
              to raise_error *syntax_error(
                'matcher.undefined_used_atom', name: :'wrong(:c)') }
            it { expect { subject.interpret("#{state} mob(:wrong)") }.
              to raise_error *syntax_error(
                'matcher.undefined_used_atom', name: :'mob(:wrong)') }

            describe "wrong names to specs" do
              subject do
                described_class.new(dimer_formation, {
                  source: [[:b, activated_bridge], [:b, df_source.last]],
                  products: [[:d, dimer]]
                })
              end

              it { expect { subject.interpret("#{state} b(:ct)") }.
                to raise_error *syntax_error(
                  'refinement.cannot_complience', name: 'b') }
            end
          end

          describe "#incoherent" do
            it_behaves_like "check state" do
              let(:state) { :incoherent }
              let(:name) { :mod }
              let(:atom) { :methyl_on_dimer }
              let(:keyname) { :cl }
            end

            describe "property is realy state" do
              before { subject.interpret("incoherent d(:cl)") }
              it { hm_source.last.atom(:cl).incoherent?.should be_true }
            end
          end

          describe "#unfixed" do
            it_behaves_like "check state" do
              let(:state) { :unfixed }
              let(:name) { :mod }
              let(:atom) { :methyl_on_dimer }
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
                  to raise_error *syntax_error('refinement.duplicate_position') }
              end
            end

            describe "incomplete" do
              it { expect { subject.interpret('position b2(:ct), b1(:ct), face: 100') }.
                to raise_error *syntax_error('position.incomplete') }
            end

            describe "wrong atom keyname" do
              it { expect { subject.interpret('position b1(:wrong), b2(:ct), face: 100, dir: front') }.
                to raise_error *syntax_error('matcher.undefined_used_atom', name: 'b1(:wrong)') }
              it { expect { subject.interpret('position b1(:ct), b2(:wrong), face: 100, dir: front') }.
                to raise_error *syntax_error('matcher.undefined_used_atom', name: 'b2(:wrong)') }
            end
          end
        end
      end

    end
  end
end
