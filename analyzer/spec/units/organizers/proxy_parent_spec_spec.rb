require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe ProxyParentSpec, type: :organizer do
      subject { (dept_dimer_base - dept_bridge_base).parents.first }

      describe '#original' do
        it { expect(subject.original).to eq(dept_bridge_base) }
      end

      describe '#==' do
        it { expect(subject).to eq(subject) }
        it { expect(subject).to eq(dept_bridge_base) }
        it { expect(subject).not_to eq(dept_dimer_base) }

        it { expect([subject] * 2).to eq([dept_bridge_base] * 2) }
      end

      describe '#<=>' do
        let(:child) { dept_methyl_on_dimer_base }
        let(:parents) { [dept_methyl_on_bridge_base, dept_bridge_base] }
        let(:proxies) do
          parents.reduce(child) { |acc, pr| acc - pr }.parents
        end

        it { expect(proxies.reverse.sort).to eq(proxies) }
      end

      describe '#method_missing' do
        describe '#same?' do
          it { expect(subject.same?(dept_bridge_base)).to be_truthy }
          it { expect(dept_bridge_base.same?(subject)).to be_truthy }

          it { expect(subject.same?(dept_dimer_base)).to be_falsey }
          it { expect(dept_dimer_base.same?(subject)).to be_falsey }
        end

        describe 'hierarchy dependent' do
          before do
            organize_base_specs_dependencies!([dept_bridge_base, dept_dimer_base])
          end

          subject { dept_dimer_base.parents.first }
          it { expect(subject).to be_a(described_class) }

          describe '#parents' do
            it { expect(subject.parents).to be_empty }
          end

          describe '#children' do
            it { expect(subject.children).to eq([dept_dimer_base] * 2) }
          end

          describe '#source?' do
            it { expect(subject.source?).to be_truthy }
          end

          describe '#complex?' do
            it { expect(subject.complex?).to be_falsey }
          end
        end
      end
    end

  end
end
