module VersatileDiamond
  module Concepts
    module Support

      module MonoInstanceNoBondExamples
        shared_examples_for :mono_instance_no_bond do
          describe '#self.property' do
            it { expect(described_class.property).to be_a(described_class) }
          end

          describe '#==' do
            it { expect(subject).to eq(described_class.new) }
            it { expect(subject).not_to eq(Object.new) }
          end

          describe '#bond?' do
            it { expect(subject.bond?).to be_falsey }
          end

          describe '#relation?' do
            it { expect(subject.relation?).to be_falsey }
          end
        end
      end

    end
  end
end
