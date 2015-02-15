require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentThere, type: :organizer do
      subject { described_class.new(dimer_formation, there_methyl) }

      describe '#each_source' do
        it { expect(subject.each_source).to be_a(Enumerator) }
        it { expect(subject.each_source.to_a).to eq([methyl_on_bridge]) }
      end

      describe '#swap_source' do
        let(:mob_dup) { methyl_on_bridge.dup }
        before { subject.swap_source(methyl_on_bridge, mob_dup) }
        it { expect(subject.each_source.to_a).to eq([mob_dup]) }
      end

      describe '#lateral_reaction' do
        it { expect(subject.lateral_reaction).to eq(dimer_formation) }
      end

      describe '#used_atoms_of' do
        let(:atoms) { [methyl_on_bridge.atom(:cb)] }
        it { expect(subject.used_atoms_of(dept_methyl_on_bridge)).to eq(atoms) }
      end

      describe '#targets' do
        shared_examples_for :check_targets do
          let(:ab) { dept_reaction.reaction.source.first }
          let(:aib) { dept_reaction.reaction.source.last }
          let(:targets) { [[ab, ab.atom(:ct)], [aib, aib.atom(:ct)]] }
          it { expect(dept_reaction.theres.first.targets).to match_array(targets) }
        end

        it_behaves_like :check_targets do
          let(:dept_reaction) { dept_end_lateral_df }
        end

        it_behaves_like :check_targets do
          let(:dept_reaction) { dept_middle_lateral_df }
        end
      end

      describe '#cover?' do
        it { expect(dept_on_middle.cover?(dept_on_end)).to be_truthy }
        it { expect(dept_on_end.cover?(dept_on_middle)).to be_falsey }
      end
    end

  end
end
