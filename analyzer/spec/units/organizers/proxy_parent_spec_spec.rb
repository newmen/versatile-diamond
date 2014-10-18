require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe ProxyParentSpec, type: :organizer do
      let(:fb_dimer_atoms) do
        [:cr, :crb, :_cr0].map { |kn| dimer_base.atom(kn) }
      end

      subject do
        described_class.new(dept_bridge_base, dept_dimer_base, fb_dimer_atoms)
      end

      describe '#==' do
        it { expect(subject).to eq(subject) }
        it { expect(subject).to eq(dept_bridge_base) }
        it { expect(subject).not_to eq(dept_dimer_base) }

        it { expect([subject] * 2).to eq([dept_bridge_base] * 2) }
      end

      describe '#relations_num' do
        it { expect(subject.relations_num).to eq(11) }
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
            2.times { dept_dimer_base.store_parent(dept_bridge_base) }
          end

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
