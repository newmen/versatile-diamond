module VersatileDiamond
  module Interpreter
    module Support

      module ReactionRefinementsExamples
        shared_examples_for "reaction refinemenets" do
          describe "special atom states" do
            subject do
              described_class.new(hydrogen_migration, hm_names_to_specs)
            end

            shared_examples_for "check state" do
              it { expect { subject.interpret(
                "#{state} #{name}(:#{keyname})") }.not_to raise_error }

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
                let(:name) { :d }
                let(:keyname) { :cl }
              end

              describe "property is realy state" do
                before(:each) { subject.interpret("incoherent d(:cl)") }
                it { expect(hm_source.last.atom(:cl).incoherent?).to be_true }
                it { expect(hm_products.last.atom(:cl).incoherent?).to be_true }
              end
            end

            describe "#unfixed" do
              it_behaves_like "check state" do
                let(:state) { :unfixed }
                let(:name) { :mod }
                let(:keyname) { :cm }
              end

              describe "property is realy state" do
                before(:each) { subject.interpret("unfixed mod(:cm)") }
                it { expect(hm_source.first.atom(:cm).unfixed?).to be_true }
                it { expect(hm_products.first.atom(:cm).unfixed?).to be_true }
              end
            end
          end

          describe "#position" do
            subject { described_class.new(dimer_formation, df_names_to_specs) }

            describe "duplication" do
              it { expect {
                  subject.interpret(
                    'position b2(:ct), b1(:ct), face: 100, dir: :front')
                }.to raise_error *syntax_warning(
                  'position.duplicate', face: 100, dir: 'front') }
            end

            describe "incomplete" do
              it { expect {
                  subject.interpret('position b2(:ct), b1(:ct), face: 100')
                }.to raise_error *syntax_error('position.incomplete') }
            end

            describe "wrong atom keyname" do
              it { expect {
                  subject.interpret(
                    'position b1(:wrong), b2(:ct), face: 100, dir: front')
                }.to raise_error *syntax_error(
                  'matcher.undefined_used_atom', name: 'b1(:wrong)') }

              it { expect {
                  subject.interpret(
                    'position b1(:ct), b2(:wrong), face: 100, dir: front')
                }.to raise_error *syntax_error(
                  'matcher.undefined_used_atom', name: 'b2(:wrong)') }
            end

            describe "different equation parts" do
              it { expect {
                  subject.interpret(
                    'position b1(:ct), d(:cl), face: 100, dir: front')
                }.to raise_error *syntax_error(
                  'refinement.different_parts', name: 'b2(:wrong)') }

            end

            describe "between surface and gas" do
              subject do
                described_class.new(methyl_desorption, md_names_to_specs)
              end

              it { expect {
                  subject.interpret(
                    'position m(:c), b(:ct), face: 100, dir: front')
                }.to raise_error *syntax_error('position.unspecified_atoms') }
            end
          end
        end
      end

    end
  end
end
